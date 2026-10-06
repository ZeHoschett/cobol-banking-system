# CB7 Bank — Sistema Bancário COBOL + Java

Sistema bancário de estudo que combina processamento COBOL batch, integração com PostgreSQL e uma API REST em Java/Spring Boot, aplicando regras comuns de negócio sobre dados compartilhados.

## Sobre o projeto

O CB7 Bank é um projeto de aprendizado e portfólio que demonstra uma evolução de processamento bancário em COBOL para uma arquitetura integrada com banco relacional e serviços Java. Ele reúne programas interativos e batch, scripts SQL, um exemplo de fluxo JCL e uma API REST.

O objetivo é praticar conceitos de programação financeira, processamento de arquivos sequenciais, persistência relacional, transações atômicas, integração com legado e desenvolvimento de serviços HTTP. A API e os programas COBOL com SQL usam as tabelas do mesmo banco PostgreSQL `cb7bank`; o programa `CB7-BATCH`, por sua vez, processa arquivos `.dat` localmente.

## Tecnologias

- **COBOL / GnuCOBOL** — processamento interativo e batch baseado em arquivos.
- **JCL** — exemplo de definição de etapas para processamento batch em ambiente mainframe.
- **SQL** — schema, carga de dados, consultas e transações com SQL embutido.
- **PostgreSQL** — banco relacional compartilhado pela API e pelos exemplos COBOL com SQL.
- **Java 17+** — linguagem da API REST.
- **Spring Boot** — endpoints REST, validação, JPA e gerenciamento transacional.
- **Maven** — dependências, build e execução dos testes Java.
- **JUnit, Spring Boot Test, MockMvc e H2** — testes automatizados da API com banco em memória.
- **Git** — versionamento do projeto.

## Arquitetura

```text
Arquivos .dat ──> CB7-BATCH (COBOL) ──> arquivos de saída e relatório

CB7DBCON / CB7DBTRS (COBOL + SQL embutido) ──┐
                                             ├──> PostgreSQL: cb7bank
cb7-api (Java + Spring Boot + JPA) ──────────┘
```

O fluxo `CB7-BATCH` lê arquivos sequenciais, mantém os saldos durante a execução e grava arquivos de saída. Ele não acessa o PostgreSQL. Os programas COBOL `CB7DBCON` e `CB7DBTRS` representam a integração via SQL embutido; a API Spring Boot acessa diretamente as tabelas `clientes`, `contas` e `transacoes`. Assim, as duas integrações com banco compartilham o schema definido neste repositório.

## Estrutura do repositório

```text
.
├── src/                 Programas COBOL interativos, batch, SQL embutido e utilitários
├── data/                Arquivos de entrada de exemplo (clientes, contas e transações)
├── output/              Saídas geradas pelo processamento COBOL
├── jcl/                 Exemplo de job JCL para fluxo batch em mainframe
├── sql/                 Schema PostgreSQL, carga de dados e consultas de exemplo
├── cb7-api/             Projeto Maven da API Spring Boot e testes automatizados
├── docs/                Documentação, incluindo casos de teste do CB7-BATCH
└── README.md            Visão geral, arquitetura e instruções do projeto
```

### Principais programas COBOL

| Programa | Finalidade |
|---|---|
| `CB7BANK.cob` | Processamento interativo com dados em memória |
| `CB7-BATCH.cob` | Processamento batch de arquivos sequenciais |
| `CB7DBCON.cob` | Consulta de cliente por CPF via SQL embutido |
| `CB7DBTRS.cob` | Processamento de transações com acesso ao banco via SQL embutido |
| `LER-CLIENTES.cob`, `LER-CONTAS.cob`, `LER-TRANSACOES.cob` | Utilitários para leitura dos arquivos de exemplo |

## Funcionalidades

- Consulta interativa de cliente e conta e processamento de transações em COBOL.
- Leitura batch de clientes, contas e transações em arquivos de largura fixa.
- Depósitos, saques e transferências, com aprovação ou recusa e motivo.
- Geração de contas atualizadas, arquivo de transações processadas e relatório.
- Consulta de clientes e processamento de transações por programas COBOL com SQL embutido.
- Consultas REST de clientes, contas com titular e extrato.
- Operações REST de depósito, saque e transferência persistidas no PostgreSQL.
- Testes automatizados da API usando H2 em memória e documentação de cenários COBOL.

## Regras de negócio

As regras centrais implementadas no processamento COBOL e na API são:

| Operação | Regras |
|---|---|
| Depósito | O valor deve ser maior que zero e o saldo resultante deve caber na capacidade numérica da conta. |
| Saque | O valor deve ser maior que zero e não pode exceder o saldo disponível. |
| Transferência | O valor deve ser maior que zero; origem e destino devem existir e ser diferentes; a origem deve ter saldo suficiente. Débito e crédito são atômicos: ambos ocorrem ou nenhum é aplicado. |

Operações recusadas não devem alterar os saldos e recebem o status `NEGADA` com o motivo correspondente. No COBOL batch, o campo monetário de entrada usa `PIC 9(11)V99`, que não representa valores negativos; essa limitação está registrada em [docs/casos-de-teste.md](./docs/casos-de-teste.md).

## Como executar

### COBOL batch e interativo

Requisitos: GnuCOBOL 3.x instalado e `cobc` disponível no `PATH`. No PowerShell, a partir da raiz do repositório:

```powershell
cobc -x -o output\CB7-BATCH.exe src\CB7-BATCH.cob
cobc -x -o output\CB7BANK.exe src\CB7BANK.cob

Copy-Item data\CLIENTES.dat, data\CONTAS.dat, data\TRANSACOES.dat output\
Push-Location output
.\CB7-BATCH.exe
# Para o modo interativo, execute em vez do batch:
# .\CB7BANK.exe
Pop-Location
```

O batch grava `CONTAS-ATUALIZADAS.dat`, `TRANSACOES-PROCESSADAS.dat` e `RELATORIO.txt` na pasta de execução. Os arquivos de saída são ignorados pelo Git.

Os utilitários `LER-*` podem ser compilados da mesma forma, por exemplo:

```powershell
cobc -x -o output\LER-CONTAS.exe src\LER-CONTAS.cob
Push-Location output
.\LER-CONTAS.exe
Pop-Location
```

### PostgreSQL

Requisito: PostgreSQL instalado e `psql` disponível. Crie o banco e aplique o schema:

```powershell
psql -U postgres -c "CREATE DATABASE cb7bank;"
psql -U postgres -d cb7bank -f sql\schema.sql
```

O schema cria as tabelas, índices, trigger e dados de exemplo. Os scripts em `sql/` também incluem cargas e consultas para explorar o banco. Evite reaplicar o schema sem antes considerar que ele contém comandos de criação e inserção de dados.

### API Java

Requisitos: Java 17+ e Maven. O README da [cb7-api](./cb7-api/README.md) contém detalhes da configuração. No PowerShell:

```powershell
$env:DB_URL = "jdbc:postgresql://localhost:5432/cb7bank"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "sua-senha"
Push-Location cb7-api
mvn spring-boot:run
Pop-Location
```

Por padrão, a API aponta para `localhost:5432/cb7bank`. Configure as credenciais para o seu ambiente; não grave senhas reais no repositório. Para executar os testes da API, que usam H2 e não precisam do PostgreSQL:

```powershell
Push-Location cb7-api
mvn test
Pop-Location
```

### SQL embutido e JCL

`CB7DBCON.cob` e `CB7DBTRS.cob` contêm SQL embutido e não compilam com GnuCOBOL puro. Para executá-los, é necessário configurar um pré-processador e uma conexão compatíveis com o ambiente SQL escolhido.

`jcl/CB7PROC.jcl` é um exemplo de job para ambiente mainframe. Ele referencia os programas `CB7VALID`, `CB7BATCH` e `CB7RELAT` e datasets `CB7.BANK.*`, que não são fornecidos como executáveis nem configurados neste repositório. Portanto, requer adaptação e ambiente JES/mainframe; não é o comando usado para executar o `CB7-BATCH.cob` local.

## Fases do desenvolvimento

1. **COBOL interativo** — consulta de cliente/conta e operações bancárias em memória (`CB7BANK.cob`).
2. **Processamento batch** — leitura de arquivos sequenciais, atualização de saldos e gravação dos resultados (`CB7-BATCH.cob`).
3. **Banco de dados** — schema PostgreSQL, dados de exemplo e consultas SQL em `sql/`.
4. **JCL** — exemplo de fluxo batch com etapas e datasets para execução em mainframe (`jcl/CB7PROC.jcl`).
5. **Regras e integridade** — consolidação de validações, motivos de recusa, tratamento de erros de arquivo e atualização atômica da transferência nos fluxos COBOL.
6. **COBOL com SQL embutido** — consulta de clientes e processamento transacional no banco, incluindo `COMMIT` e `ROLLBACK` (`CB7DBCON.cob` e `CB7DBTRS.cob`).
7. **API REST Java** — endpoints Spring Boot para consultas e operações bancárias no mesmo PostgreSQL.
8. **Testes e qualidade** — testes de integração da API com JUnit/Spring Boot Test/H2 e documentação dos cenários do `CB7-BATCH`.
9. **Documentação e portfólio** — documentação da arquitetura, das instruções de execução, dos limites do projeto e dos casos de teste.

## O que este projeto demonstra

- Integração entre COBOL, SQL e uma API Java moderna sobre um schema compartilhado.
- Modelagem relacional e consultas PostgreSQL.
- Regras financeiras, validação de dados e controle de consistência transacional.
- Processamento batch, arquivos de largura fixa, JCL e tratamento de falhas.
- Organização de código por camadas em Spring Boot e testes automatizados.
- Capacidade de documentar decisões, execução e limitações técnicas.

## Observações

Este é um **projeto de estudo e portfólio**, desenvolvido para praticar e demonstrar conceitos. Ele não representa experiência profissional, emprego ou atuação comercial com COBOL, JCL, PostgreSQL, Java ou Spring Boot. O sistema também não é um produto bancário pronto para produção: autenticação, autorização, observabilidade, segurança operacional e diversos controles necessários a um serviço financeiro real estão fora do escopo.
