-- ============================================================
--  CB7BANK — cria o banco e roda o schema completo de uma vez
--  Uso (no terminal, psql pedira a senha uma vez):
--    psql -U postgres -f criar_tudo.sql
-- ============================================================

-- 1) Cria o banco cb7bank somente se ele ainda nao existir
SELECT 'CREATE DATABASE cb7bank'
 WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'cb7bank')\gexec

-- 2) Conecta no banco recem-criado
\c cb7bank

-- 3) Executa o schema (tabelas, indices, trigger e dados de exemplo)
\ir schema.sql

-- 4) Conferencia rapida
\echo '--- Tabelas criadas ---'
\dt
\echo '--- Clientes x Contas ---'
SELECT c.nome_completo, ct.numero_conta, ct.saldo
  FROM contas ct JOIN clientes c ON c.id = ct.cliente_id;
