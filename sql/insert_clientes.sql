-- cb7bank: 3 novos clientes + contas correntes (ag 0001) com saldo de 15.000,00
-- id, uuid, status, criado_em e atualizado_em usam os defaults do schema.
SET client_encoding = 'UTF8';
BEGIN;

INSERT INTO clientes (nome_completo, cpf, email, telefone, data_nascimento, senha_hash) VALUES
  ('Maria da Silva', '45678901234', 'maria.silva@cb7bank.com',  '11900000001', DATE '1990-01-01', 'PENDENTE_DEFINIR_SENHA'),
  ('João Pereira',   '23456789012', 'joao.pereira@cb7bank.com', '11900000002', DATE '1990-01-01', 'PENDENTE_DEFINIR_SENHA'),
  ('Ana Costa',      '34567890123', 'ana.costa@cb7bank.com',    '11900000003', DATE '1990-01-01', 'PENDENTE_DEFINIR_SENHA');

INSERT INTO contas (cliente_id, agencia, numero_conta, tipo, saldo, limite)
SELECT c.id, '0001', v.numero_conta, 'CORRENTE', 15000.00, 0.00
FROM (VALUES
  ('45678901234', '0001234567'),
  ('23456789012', '0001234568'),
  ('34567890123', '0001234569')
) AS v(cpf, numero_conta)
JOIN clientes c ON c.cpf = v.cpf;

-- Depósito inicial, para o saldo ter lastro no extrato
INSERT INTO transacoes (conta_destino_id, tipo, valor, descricao)
SELECT ct.id, 'DEPOSITO', 15000.00, 'Depósito inicial de abertura de conta'
FROM contas ct
WHERE ct.agencia = '0001' AND ct.numero_conta IN ('0001234567', '0001234568', '0001234569');

COMMIT;

