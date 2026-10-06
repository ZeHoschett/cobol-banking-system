# Casos de Teste — CB7-BATCH (Processamento Batch COBOL)

Os cenários abaixo foram executados individualmente com os arquivos de exemplo em `data/`. Cada execução começou com os saldos originais: conta `0001234567` com 1.500,00, conta `0007654321` com 2.500,00 e conta `0009876543` com 500,00. O resultado foi conferido em `TRANSACOES-PROCESSADAS.dat` e, nos cenários aprovados, em `CONTAS-ATUALIZADAS.dat`.

Na coluna **Entrada**, valores são apresentados em reais. No arquivo `TRANSACOES.dat`, cada valor é gravado sem separador decimal em 13 posições; tipo `1` = depósito, `2` = saque, `3` = transferência.

## Cenários Positivos

| # | Cenário | Entrada | Resultado Esperado | Status |
|---|---------|---------|-------------------|--------|
| 1 | Depósito válido | Conta `0001234567`, valor `500,00` | Saldo passa de `1.500,00` para `2.000,00`; transação `APROVADA` | OK |
| 2 | Saque com saldo suficiente | Conta `0007654321`, valor `1.000,00` | Saldo passa de `2.500,00` para `1.500,00`; transação `APROVADA` | OK |
| 3 | Transferência válida | Origem `0001234567`, destino `0009876543`, valor `300,00` | Origem passa a `1.200,00`, destino passa a `800,00`; transação `APROVADA` | OK |

## Cenários Negativos

| # | Cenário | Entrada | Resultado Esperado | Status |
|---|---------|---------|-------------------|--------|
| 4 | Saque sem saldo | Conta `0007654321`, valor `3.000,00` (saldo inicial `2.500,00`) | `NEGADA`, motivo `Saldo insuficiente`; saldo permanece `2.500,00` | OK |
| 5 | Valor zero | Depósito na conta `0001234567`, valor `0,00` | `NEGADA`, motivo `Valor deve ser maior que zero`; saldo permanece `1.500,00` | OK |
| 6 | Valor negativo | Depósito na conta `0001234567`, valor `-10,00` | A entrada deve ser rejeitada como inválida; saldo não pode ser alterado | Não executado — limitação do layout |
| 7 | Conta origem inexistente | Depósito na conta `0001111111`, valor `1,00` | `NEGADA`, motivo `Conta origem nao encontrada` | OK |
| 8 | Conta destino inexistente | Transferência de `0001234567` para `0001111111`, valor `1,00` | `NEGADA`, motivo `Conta destino nao encontrada`; saldos permanecem inalterados | OK |
| 9 | Transferência destino = origem | Transferência de `0001234567` para `0001234567`, valor `1,00` | `NEGADA`, motivo `Conta destino igual a origem`; saldo permanece `1.500,00` | OK |
| 10 | Tipo de transação inválido | Tipo `9`, conta `0001234567`, valor `1,00` | `NEGADA`, motivo `Tipo de transacao invalido`; saldo permanece `1.500,00` | OK |

## Observação sobre valor negativo

O campo do valor no layout de `TRANSACOES.dat` é `PIC 9(11)V99`, sem sinal. Portanto, `-10,00` não é um valor representável por um registro numérico válido nesse formato. O cenário negativo fica documentado como uma limitação de entrada; para testá-lo de ponta a ponta, será necessário alterar o layout para um campo com sinal ou validar e rejeitar a entrada textual antes de interpretá-la como número.
