package com.cb7bank.api.dto;

import java.time.LocalDate;

public record ClienteResponse(
        String cpf,
        String nome,
        String email,
        String telefone,
        LocalDate dataNascimento,
        String status
) {
}
