package com.cb7bank.api.dto;

public record ApiErrorResponse(String status, String motivo) {
    public static ApiErrorResponse negada(String motivo) {
        return new ApiErrorResponse("NEGADA", motivo);
    }
}
