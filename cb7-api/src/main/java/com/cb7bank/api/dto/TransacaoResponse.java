package com.cb7bank.api.dto;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

public record TransacaoResponse(
        Long id,
        String tipo,
        BigDecimal valor,
        String descricao,
        String status,
        OffsetDateTime criadoEm,
        String contaOrigem,
        String contaDestino
) {
}
