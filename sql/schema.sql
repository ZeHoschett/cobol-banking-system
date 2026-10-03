-- ============================================================
--  CB7BANK — Schema do banco de dados
--  PostgreSQL
--
--  Como usar no pgAdmin:
--   1) Conectado ao banco "postgres", rode apenas:
--          CREATE DATABASE cb7bank;
--   2) Reconecte ao banco "cb7bank" (Query Tool nele)
--   3) Rode este arquivo inteiro (a partir do bloco abaixo).
--
--  Ou via terminal:
--   psql -U postgres -c "CREATE DATABASE cb7bank;"
--   psql -U postgres -d cb7bank -f schema.sql
-- ============================================================

-- Extensão para gerar UUIDs
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- ------------------------------------------------------------
-- CLIENTES
-- ------------------------------------------------------------
CREATE TABLE clientes (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid            UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    nome_completo   VARCHAR(150) NOT NULL,
    cpf             CHAR(11)     NOT NULL UNIQUE,
    email           VARCHAR(160) NOT NULL UNIQUE,
    telefone        VARCHAR(20),
    data_nascimento DATE         NOT NULL,
    senha_hash      VARCHAR(255) NOT NULL,          -- nunca guarde senha em texto puro
    status          VARCHAR(20)  NOT NULL DEFAULT 'ATIVO'
                    CHECK (status IN ('ATIVO','INATIVO','BLOQUEADO')),
    criado_em       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    atualizado_em   TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- CONTAS  (um cliente pode ter várias contas)
-- ------------------------------------------------------------
CREATE TABLE contas (
    id              BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid            UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    cliente_id      BIGINT NOT NULL REFERENCES clientes(id),
    agencia         CHAR(4)  NOT NULL DEFAULT '0001',
    numero_conta    VARCHAR(12) NOT NULL,
    tipo            VARCHAR(20) NOT NULL
                    CHECK (tipo IN ('CORRENTE','POUPANCA','PAGAMENTO')),
    saldo           NUMERIC(15,2) NOT NULL DEFAULT 0.00
                    CHECK (saldo >= 0),
    limite          NUMERIC(15,2) NOT NULL DEFAULT 0.00,
    status          VARCHAR(20) NOT NULL DEFAULT 'ATIVA'
                    CHECK (status IN ('ATIVA','ENCERRADA','BLOQUEADA')),
    criado_em       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    atualizado_em   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (agencia, numero_conta)
);

-- ------------------------------------------------------------
-- CARTÕES
-- ------------------------------------------------------------
CREATE TABLE cartoes (
    id               BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid             UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    conta_id         BIGINT NOT NULL REFERENCES contas(id),
    numero_mascarado CHAR(19) NOT NULL,             -- ex: '**** **** **** 1234'
    titular          VARCHAR(150) NOT NULL,
    bandeira         VARCHAR(20) NOT NULL
                     CHECK (bandeira IN ('VISA','MASTERCARD','ELO','AMEX')),
    tipo             VARCHAR(20) NOT NULL
                     CHECK (tipo IN ('DEBITO','CREDITO','MULTIPLO')),
    validade         DATE NOT NULL,
    status           VARCHAR(20) NOT NULL DEFAULT 'ATIVO'
                     CHECK (status IN ('ATIVO','BLOQUEADO','CANCELADO')),
    criado_em        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ------------------------------------------------------------
-- TRANSAÇÕES  (histórico de movimentações)
-- ------------------------------------------------------------
CREATE TABLE transacoes (
    id                BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    uuid              UUID NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    conta_origem_id   BIGINT REFERENCES contas(id),   -- NULL em depósito externo
    conta_destino_id  BIGINT REFERENCES contas(id),   -- NULL em saque externo
    tipo              VARCHAR(20) NOT NULL
                      CHECK (tipo IN ('DEPOSITO','SAQUE','TRANSFERENCIA','PIX','PAGAMENTO')),
    valor             NUMERIC(15,2) NOT NULL CHECK (valor > 0),
    descricao         VARCHAR(255),
    status            VARCHAR(20) NOT NULL DEFAULT 'CONCLUIDA'
                      CHECK (status IN ('PENDENTE','CONCLUIDA','FALHOU','ESTORNADA')),
    criado_em         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
--  ÍNDICES  (aceleram as consultas mais frequentes)
-- ============================================================
CREATE INDEX idx_contas_cliente     ON contas(cliente_id);
CREATE INDEX idx_cartoes_conta      ON cartoes(conta_id);
CREATE INDEX idx_transacoes_origem  ON transacoes(conta_origem_id);
CREATE INDEX idx_transacoes_destino ON transacoes(conta_destino_id);
CREATE INDEX idx_transacoes_data    ON transacoes(criado_em);

-- ============================================================
--  TRIGGER — atualiza "atualizado_em" automaticamente
--  a cada UPDATE nas tabelas que têm essa coluna.
-- ============================================================
CREATE OR REPLACE FUNCTION set_atualizado_em()
RETURNS TRIGGER AS $$
BEGIN
    NEW.atualizado_em = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_clientes_atualizado
    BEFORE UPDATE ON clientes
    FOR EACH ROW EXECUTE FUNCTION set_atualizado_em();

CREATE TRIGGER trg_contas_atualizado
    BEFORE UPDATE ON contas
    FOR EACH ROW EXECUTE FUNCTION set_atualizado_em();

-- ============================================================
--  DADOS DE EXEMPLO  (para testar as tabelas)
--  Obs.: senha_hash abaixo é apenas ilustrativa.
-- ============================================================
INSERT INTO clientes (nome_completo, cpf, email, telefone, data_nascimento, senha_hash)
VALUES
    ('Camila Souza',     '12345678901', 'camila@cb7bank.com', '11999990001', '1995-04-15', '$2a$10$exemplohashfake1'),
    ('João Pereira',     '98765432100', 'joao@cb7bank.com',   '11999990002', '1988-11-02', '$2a$10$exemplohashfake2'),
    ('Maria Fernandes',  '45678912300', 'maria@cb7bank.com',  '11999990003', '2000-07-27', '$2a$10$exemplohashfake3');

INSERT INTO contas (cliente_id, agencia, numero_conta, tipo, saldo, limite)
VALUES
    (1, '0001', '000000012345', 'CORRENTE', 2500.00, 1000.00),
    (2, '0001', '000000067890', 'POUPANCA',  800.50,    0.00),
    (3, '0001', '000000054321', 'PAGAMENTO', 150.00,    0.00);

INSERT INTO cartoes (conta_id, numero_mascarado, titular, bandeira, tipo, validade)
VALUES
    (1, '**** **** **** 1234', 'CAMILA SOUZA',    'VISA',       'MULTIPLO', '2030-04-30'),
    (2, '**** **** **** 5678', 'JOAO PEREIRA',    'MASTERCARD', 'DEBITO',   '2029-11-30');

INSERT INTO transacoes (conta_origem_id, conta_destino_id, tipo, valor, descricao)
VALUES
    (NULL, 1, 'DEPOSITO',       2500.00, 'Deposito inicial'),
    (1,    2, 'TRANSFERENCIA',   300.00, 'Transferencia para Joao'),
    (1,    3, 'PIX',             150.00, 'PIX para Maria');

-- ============================================================
--  CONSULTAS ÚTEIS PARA CONFERIR
-- ============================================================
-- SELECT * FROM clientes;
-- SELECT c.nome_completo, ct.numero_conta, ct.saldo
--   FROM contas ct JOIN clientes c ON c.id = ct.cliente_id;
-- SELECT * FROM transacoes ORDER BY criado_em DESC;
