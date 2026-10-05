# CB7 Bank — Sistema Bancário em COBOL

Sistema de processamento bancário desenvolvido em COBOL, cobrindo processamento interativo e batch, regras de negócio financeiras (depósito, saque e transferência) e tratamento de arquivos sequenciais com `FILE STATUS`.

## Funcionalidades

- **Fase 1 — Processamento interativo** (`CB7BANK.cob`): o operador informa o CPF, escolhe uma das contas vinculadas e executa transações pelo terminal, em loop, até optar por sair.
- **Fase 2 — Processamento batch** (`CB7-BATCH.cob`): lê clientes, contas e transações de arquivos, aplica as regras de negócio e grava as contas atualizadas, o log de transações processadas e um relatório formatado.
- **Fase 6 — COBOL com SQL embutido** (`CB7DBCON.cob`, `CB7DBTRS.cob`): consulta clientes por CPF e processa transações de um arquivo de entrada diretamente no banco, com `COMMIT`/`ROLLBACK`.
- **Validações**: conta de origem e destino existentes, destino diferente da origem, valor maior que zero, saldo suficiente e estouro de capacidade dos campos numéricos (`ON SIZE ERROR`).
- **Transferência atômica**: os dois novos saldos são calculados antes de qualquer alteração; se um dos cálculos falhar, nenhuma conta é modificada.
- **Transferência SQL atômica**: débito, crédito e registro da transferência são executados na mesma unidade de trabalho; a operação só é aprovada depois do `COMMIT`.
- **Tratamento de erros**: todas as operações de `OPEN`, `READ`, `WRITE` e `CLOSE` verificam o `FILE STATUS`; erros de arquivo interrompem o processamento de forma controlada.

## Estrutura do projeto

```
src/
  CB7BANK.cob          Fase 1 — processamento interativo (dados em memória)
  CB7-BATCH.cob        Fase 2 — processamento batch com arquivos
  CB7DBCON.cob         Fase 6 — consulta de cliente com SQL embutido
  CB7DBTRS.cob         Fase 6 — processamento de transações com SQL embutido
  LER-CLIENTES.cob     Utilitário: lista os registros de CLIENTES.dat
  LER-CONTAS.cob       Utilitário: lista os registros de CONTAS.dat
  LER-TRANSACOES.cob   Utilitário: lista os registros de TRANSACOES.dat
data/                  Arquivos de entrada de exemplo
output/                Arquivos gerados pelo processamento (ignorados pelo Git)
docs/                  Documentação
```

## Requisitos

- [GnuCOBOL](https://gnucobol.sourceforge.io/) 3.x (testado com 3.3-dev)

Os programas `CB7DBCON.cob` e `CB7DBTRS.cob` contêm SQL embutido e **não compilam com GnuCOBOL puro**. Para pré-processá-los, é necessário um pré-processador compatível, como o do DB2 ou OCESQL, além de uma conexão configurada com o banco.

## Como compilar e executar

Os programas abrem os arquivos pelo nome, sem caminho, a partir da pasta em que são executados. Por isso, a forma mais simples é compilar e rodar dentro de `output/`, copiando para lá os arquivos de entrada:

```bash
cd output
cp ../data/*.dat .

# Fase 2 — batch
cobc -x -o CB7-BATCH ../src/CB7-BATCH.cob
./CB7-BATCH

# Fase 1 — interativo
cobc -x -o CB7BANK ../src/CB7BANK.cob
./CB7BANK
```

Os utilitários `LER-*` são compilados e executados da mesma forma.

> No Windows, a pasta `bin` do GnuCOBOL precisa estar no `PATH` para que os executáveis encontrem a `libcob`.

## SQL embutido (Fase 6)

- **`CB7DBCON`** recebe um CPF e consulta `CLIENTES`, exibindo CPF, nome, e-mail e telefone. Trata `SQLCODE` igual a `0` (encontrado), `100` (não encontrado) e negativo (erro); a variável indicadora do telefone permite tratar o campo nulo.
- **`CB7DBTRS`** lê `TRANSACOES.dat` no mesmo layout descrito abaixo e consulta as contas no banco. Tipos `1`, `2` e `3` representam depósito, saque e transferência. A agência é fixada em `0001`, pois o layout de entrada contém apenas os números das contas. Para depósito, o campo de conta origem indica a conta que recebe o valor.
- Nas operações aprovadas, o programa atualiza o saldo e grava a operação em `TRANSACOES`; cada registro aprovado é confirmado individualmente com `COMMIT`. Operações rejeitadas fazem `ROLLBACK`. Os `UPDATE`s verificam `SQLCODE` e `SQLERRD(3)`; saques e transferências também verificam o saldo no próprio `UPDATE`.
- O SQL usa tabelas e colunas do schema do projeto (`CLIENTES`, `CONTAS` e `TRANSACOES`). O schema disponível em `sql/schema.sql` está escrito para PostgreSQL; o SQL embutido precisa ser pré-processado e adaptado ao banco e ao pré-processador escolhido antes da execução.

Saída esperada do batch com os dados de exemplo:

```
RESUMO DO PROCESSAMENTO
Transacoes lidas:         3
Aprovadas:                3
Negadas:                  0
```

## Layout dos arquivos

Todos os arquivos são `LINE SEQUENTIAL` com campos de largura fixa. Valores monetários usam `PIC 9(11)V99`: 13 dígitos com 2 casas decimais implícitas (`0000000150000` = 1.500,00).

### Entrada

**`CLIENTES.dat`** — 92 posições

| Campo    | PIC     | Posições |
|----------|---------|----------|
| CPF      | X(11)   | 1–11     |
| Nome     | X(40)   | 12–51    |
| Telefone | X(11)   | 52–62    |
| E-mail   | X(30)   | 63–92    |

**`CONTAS.dat`** — 48 posições

| Campo   | PIC        | Posições |
|---------|------------|----------|
| Número  | X(10)      | 1–10     |
| Agência | X(4)       | 11–14    |
| Tipo    | X(10)      | 15–24    |
| Saldo   | 9(11)V99   | 25–37    |
| CPF     | X(11)      | 38–48    |

**`TRANSACOES.dat`** — 34 posições

| Campo         | PIC       | Posições |
|---------------|-----------|----------|
| Conta origem  | X(10)     | 1–10     |
| Tipo          | 9         | 11       |
| Valor         | 9(11)V99  | 12–24    |
| Conta destino | X(10)     | 25–34    |

Tipos de transação: `1` = depósito, `2` = saque, `3` = transferência. A conta destino só é usada em transferências.

### Saída

| Arquivo                      | Conteúdo |
|------------------------------|----------|
| `CONTAS-ATUALIZADAS.dat`     | Contas com os saldos finais, no mesmo layout de `CONTAS.dat` |
| `TRANSACOES-PROCESSADAS.dat` | Uma linha por transação, separada por `\|`: origem, tipo, valor, destino, status (`APROVADA`/`NEGADA`) e motivo da recusa |
| `RELATORIO.txt`              | Relatório com a lista de transações, totais de aprovadas/negadas, valores por tipo e saldo final de cada conta |

Exemplo de `TRANSACOES-PROCESSADAS.dat`:

```
0001234567|1|        500.00|          |APROVADA|
0007654321|2|       1000.00|          |APROVADA|
0001234567|3|        300.00|0009876543|APROVADA|
```

## Regras de negócio

| Operação       | Regras |
|----------------|--------|
| Depósito       | Valor > 0; o novo saldo deve caber no campo |
| Saque          | Valor > 0; valor ≤ saldo da conta |
| Transferência  | Valor > 0; conta destino existente e diferente da origem; valor ≤ saldo da origem; os dois saldos são atualizados juntos ou nenhum é |

Transações recusadas recebem status `NEGADA` com o motivo (por exemplo, `Saldo insuficiente`, `Conta destino nao encontrada`) e não alteram os saldos.

## Limites

- Batch: até 100 clientes e 100 contas carregados em memória. Acima disso, o processamento é interrompido.
- Interativo: 3 clientes e 3 contas fixos no programa.
