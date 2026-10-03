\set ON_ERROR_STOP on
SET client_encoding = 'UTF8';

-- 1) Depósito de 500 na conta da Maria da Silva (0001 / 0001234567)
BEGIN;
UPDATE contas SET saldo = saldo + 500.00, atualizado_em = now()
WHERE agencia = '0001' AND numero_conta = '0001234567';
INSERT INTO transacoes (conta_destino_id, tipo, valor, descricao, status)
SELECT id, 'DEPOSITO', 500.00, 'Depósito em conta', 'CONCLUIDA'
FROM contas WHERE agencia = '0001' AND numero_conta = '0001234567';
COMMIT;

-- 2) Saque de 1000 na conta do João Pereira (0001 / 0001234568)
BEGIN;
UPDATE contas SET saldo = saldo - 1000.00, atualizado_em = now()
WHERE agencia = '0001' AND numero_conta = '0001234568';
INSERT INTO transacoes (conta_origem_id, tipo, valor, descricao, status)
SELECT id, 'SAQUE', 1000.00, 'Saque em conta', 'CONCLUIDA'
FROM contas WHERE agencia = '0001' AND numero_conta = '0001234568';
COMMIT;

-- 3) Transferência de 300 da Maria (0001234567) para a Ana (0001234569)
BEGIN;
UPDATE contas SET saldo = saldo - 300.00, atualizado_em = now()
WHERE agencia = '0001' AND numero_conta = '0001234567';
UPDATE contas SET saldo = saldo + 300.00, atualizado_em = now()
WHERE agencia = '0001' AND numero_conta = '0001234569';
INSERT INTO transacoes (conta_origem_id, conta_destino_id, tipo, valor, descricao, status)
SELECT o.id, d.id, 'TRANSFERENCIA', 300.00, 'Transferência Maria da Silva -> Ana Costa', 'CONCLUIDA'
FROM contas o, contas d
WHERE o.agencia = '0001' AND o.numero_conta = '0001234567'
  AND d.agencia = '0001' AND d.numero_conta = '0001234569';
COMMIT;
