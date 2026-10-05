package com.cb7bank.api.dto;

import java.math.BigDecimal;

public record ContaResponse(
        String numeroConta,
        String agencia,
        String tipo,
        BigDecimal saldo,
        BigDecimal limite,
        String status,
        String nomeTitular
) {
}
