# cb7-api

API REST em Spring Boot para acessar o mesmo banco PostgreSQL `cb7bank` usado pelo COBOL. A aplicação mapeia o schema existente em `../sql/schema.sql`; ela não cria nem modifica tabelas (`ddl-auto=validate`).

## Requisitos e execução

- Java 17+
- Maven 3.6+
- PostgreSQL com o banco `cb7bank` e o schema do repositório já aplicados

Na pasta `cb7-api`, configure as credenciais do banco por variáveis de ambiente e execute:

```powershell
$env:DB_URL = "jdbc:postgresql://localhost:5432/cb7bank"
$env:DB_USERNAME = "postgres"
$env:DB_PASSWORD = "sua-senha"
mvn spring-boot:run
```

Os valores padrão são URL `jdbc:postgresql://localhost:5432/cb7bank`, usuário `postgres` e senha `postgres`. Sobrescreva-os no seu ambiente. Para validar e empacotar, rode `mvn test` e `mvn package`.

## Endpoints

| Método | Caminho | Resultado |
|---|---|---|
| GET | `/api/clientes/{cpf}` | Dados públicos do cliente; o hash de senha nunca é retornado |
| GET | `/api/contas/{numeroConta}` | Conta e nome do titular |
| GET | `/api/contas/{numeroConta}/extrato` | Transações em que a conta é origem ou destino, mais recentes primeiro |
| POST | `/api/transacoes/deposito` | Depósito na conta informada em `conta` |
| POST | `/api/transacoes/saque` | Saque da conta informada em `conta` |
| POST | `/api/transacoes/transferencia` | Transferência entre `contaOrigem` e `contaDestino` |

Exemplos de corpos POST:

```json
{"conta":"000000012345","valor":50.00}
```

```json
{"contaOrigem":"000000012345","contaDestino":"000000067890","valor":25.00}
```

Operações aprovadas retornam HTTP 200 com `status: "APROVADA"`. Falhas de validação do corpo retornam 400; conta ou cliente inexistente retorna 404; regras de negócio violadas (valor não positivo, saldo insuficiente, origem igual ao destino ou saldo fora da precisão suportada pelo banco) retornam 422. Respostas de operação negada contêm `status: "NEGADA"` e `motivo`.

Cada operação altera saldos e insere a linha correspondente em `transacoes` na mesma transação Spring. Bloqueios pessimistas evitam saques concorrentes sobre saldo desatualizado; transferências bloqueiam as duas contas em ordem determinística. Depósitos usam a conta como destino, saques como origem e transferências registram origem e destino, conforme o modelo do COBOL.

Os números de conta são consultados na agência `0001`, a mesma agência fixa usada por `CB7DBTRS.cob`.
