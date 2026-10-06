package com.cb7bank.api;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.MOCK,
        properties = {
                "spring.datasource.url=jdbc:h2:mem:cb7test;MODE=PostgreSQL;DATABASE_TO_LOWER=TRUE",
                "spring.datasource.username=sa",
                "spring.datasource.password=",
                "spring.datasource.driver-class-name=org.h2.Driver",
                "spring.jpa.database-platform=org.hibernate.dialect.H2Dialect",
                "spring.jpa.hibernate.ddl-auto=create-drop"
        }
)
@AutoConfigureMockMvc
class TransacaoApiIntegrationTest {

    private static final String CONTA_ORIGEM = "000000012345";
    private static final String CONTA_DESTINO = "000000067890";

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @BeforeEach
    void prepararBancoDeTeste() {
        jdbcTemplate.update("DELETE FROM transacoes");
        jdbcTemplate.update("DELETE FROM contas");
        jdbcTemplate.update("DELETE FROM clientes");

        jdbcTemplate.update("""
                INSERT INTO clientes
                    (uuid, nome_completo, cpf, email, telefone, data_nascimento, senha_hash, status)
                VALUES
                    ('00000000-0000-0000-0000-000000000001', 'Cliente Teste', '12345678901',
                     'teste@cb7bank.com', '11999990000', DATE '1990-01-01', 'hash-teste', 'ATIVO')
                """);

        jdbcTemplate.update("""
                INSERT INTO contas
                    (uuid, cliente_id, agencia, numero_conta, tipo, saldo, limite, status,
                     criado_em, atualizado_em)
                VALUES
                    ('00000000-0000-0000-0000-000000000011',
                     (SELECT id FROM clientes WHERE cpf = '12345678901'),
                     '0001', ?, 'CORRENTE', 100.00, 0.00, 'ATIVA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
                    ('00000000-0000-0000-0000-000000000012',
                     (SELECT id FROM clientes WHERE cpf = '12345678901'),
                     '0001', ?, 'CORRENTE', 50.00, 0.00, 'ATIVA', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
                """, CONTA_ORIGEM, CONTA_DESTINO);
    }

    @Test
    void depositoValidoAprovaEAtualizaSaldo() throws Exception {
        mockMvc.perform(post("/api/transacoes/deposito")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"conta":"000000012345","valor":25.00}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APROVADA"))
                .andExpect(jsonPath("$.saldoAtualizado").value(125.00));

        assertThat(saldo(CONTA_ORIGEM)).isEqualByComparingTo("125.00");
    }

    @Test
    void saqueMenorQueSaldoAprovaEAtualizaSaldo() throws Exception {
        mockMvc.perform(post("/api/transacoes/saque")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"conta":"000000012345","valor":25.00}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APROVADA"))
                .andExpect(jsonPath("$.saldoAtualizado").value(75.00));

        assertThat(saldo(CONTA_ORIGEM)).isEqualByComparingTo("75.00");
    }

    @Test
    void transferenciaAprovaEDebitaOrigemECreditaDestino() throws Exception {
        mockMvc.perform(post("/api/transacoes/transferencia")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"contaOrigem":"000000012345","contaDestino":"000000067890","valor":30.00}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("APROVADA"))
                .andExpect(jsonPath("$.saldoAtualizado").value(70.00));

        assertThat(saldo(CONTA_ORIGEM)).isEqualByComparingTo("70.00");
        assertThat(saldo(CONTA_DESTINO)).isEqualByComparingTo("80.00");
    }

    @Test
    void saqueAcimaDoSaldoRetornaNegada() throws Exception {
        mockMvc.perform(post("/api/transacoes/saque")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"conta":"000000012345","valor":100.01}
                                """))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value("NEGADA"))
                .andExpect(jsonPath("$.motivo").value("Saldo insuficiente"));
    }

    @Test
    void depositoComValorZeroRetornaNegada() throws Exception {
        mockMvc.perform(post("/api/transacoes/deposito")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"conta":"000000012345","valor":0}
                                """))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value("NEGADA"))
                .andExpect(jsonPath("$.motivo").value("Valor deve ser maior que zero"));
    }

    @Test
    void depositoComValorNegativoRetornaNegada() throws Exception {
        mockMvc.perform(post("/api/transacoes/deposito")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"conta":"000000012345","valor":-10.00}
                                """))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value("NEGADA"))
                .andExpect(jsonPath("$.motivo").value("Valor deve ser maior que zero"));
    }

    @Test
    void transferenciaParaMesmaContaRetornaNegada() throws Exception {
        mockMvc.perform(post("/api/transacoes/transferencia")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"contaOrigem":"000000012345","contaDestino":"000000012345","valor":10.00}
                                """))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value("NEGADA"))
                .andExpect(jsonPath("$.motivo")
                        .value("Conta destino deve ser diferente da conta origem"));
    }

    @Test
    void saqueDeContaInexistenteRetorna404() throws Exception {
        mockMvc.perform(post("/api/transacoes/saque")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"conta":"999999999999","valor":10.00}
                                """))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value("NEGADA"))
                .andExpect(jsonPath("$.motivo").value("Conta não encontrada"));
    }

    @Test
    void transferenciaSemSaldoSuficienteNaoAlteraNenhumSaldo() throws Exception {
        BigDecimal saldoOrigemAntes = saldo(CONTA_ORIGEM);
        BigDecimal saldoDestinoAntes = saldo(CONTA_DESTINO);

        mockMvc.perform(post("/api/transacoes/transferencia")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"contaOrigem":"000000012345","contaDestino":"000000067890","valor":150.00}
                                """))
                .andExpect(status().isUnprocessableEntity())
                .andExpect(jsonPath("$.status").value("NEGADA"))
                .andExpect(jsonPath("$.motivo").value("Saldo insuficiente"));

        assertThat(saldo(CONTA_ORIGEM)).isEqualByComparingTo(saldoOrigemAntes);
        assertThat(saldo(CONTA_DESTINO)).isEqualByComparingTo(saldoDestinoAntes);
        assertThat(transacoesRegistradas()).isZero();
    }

    private BigDecimal saldo(String numeroConta) {
        return jdbcTemplate.queryForObject(
                "SELECT saldo FROM contas WHERE numero_conta = ?",
                BigDecimal.class,
                numeroConta
        );
    }

    private int transacoesRegistradas() {
        return jdbcTemplate.queryForObject("SELECT COUNT(*) FROM transacoes", Integer.class);
    }
}
