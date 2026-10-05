package com.cb7bank.api.dto;

import com.fasterxml.jackson.annotation.JsonInclude;

import java.math.BigDecimal;

@JsonInclude(JsonInclude.Include.NON_NULL)
public record OperacaoResponse(
        String status,
        String motivo,
        Long transacaoId,
        BigDecimal saldoAtualizado
) {
    public static OperacaoResponse aprovada(Long transacaoId, BigDecimal saldoAtualizado) {
        return new OperacaoResponse("APROVADA", null, transacaoId, saldoAtualizado);
    }

    public static OperacaoResponse negada(String motivo) {
        return new OperacaoResponse("NEGADA", motivo, null, null);
    }
}
