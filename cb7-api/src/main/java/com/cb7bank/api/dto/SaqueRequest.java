package com.cb7bank.api.dto;

import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.math.BigDecimal;

public record SaqueRequest(
        @NotBlank String conta,
        @NotNull @Digits(integer = 13, fraction = 2) BigDecimal valor
) {
}
