-- ============================================================
--  CB7BANK — Consultas de negócio
--  psql -U postgres -d cb7bank -f consultas.sql
-- ============================================================

-- 1) Simples: todos os clientes (nome e CPF)
SELECT nome_completo, cpf
FROM clientes
ORDER BY nome_completo;

-- 2) Filtro: conta do cliente pelo CPF
SELECT ct.agencia, ct.numero_conta, ct.tipo, ct.saldo, ct.status
FROM contas ct
JOIN clientes c ON c.id = ct.cliente_id
WHERE c.cpf = '45678901234';

-- 3) JOIN: contas com o nome do dono (base para o programa COBOL)
SELECT c.nome_completo, ct.numero_conta, ct.tipo, ct.saldo
FROM contas ct
JOIN clientes c ON c.id = ct.cliente_id
ORDER BY c.nome_completo;

-- 4) Agregação: saldo total de todas as contas do banco
SELECT SUM(saldo) AS saldo_total
FROM contas;

-- 5) Relatório de transações (mesmo relatório do COBOL) — JOIN de 3 tabelas
--    Depósito aparece na conta de destino; saque/transferência na de origem.
SELECT c.nome_completo                               AS cliente,
       ct.numero_conta                               AS conta,
       t.tipo,
       t.valor,
       t.status,
       to_char(t.criado_em, 'DD/MM/YYYY HH24:MI:SS') AS data
FROM transacoes t
JOIN contas   ct ON ct.id = COALESCE(t.conta_origem_id, t.conta_destino_id)
JOIN clientes c  ON c.id  = ct.cliente_id
ORDER BY t.criado_em, t.id;
