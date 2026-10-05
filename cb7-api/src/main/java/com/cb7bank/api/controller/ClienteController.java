package com.cb7bank.api.controller;

import com.cb7bank.api.dto.ClienteResponse;
import com.cb7bank.api.service.BankingService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/clientes")
public class ClienteController {

    private final BankingService bankingService;

    public ClienteController(BankingService bankingService) {
        this.bankingService = bankingService;
    }

    @GetMapping("/{cpf}")
    public ClienteResponse buscarPorCpf(@PathVariable String cpf) {
        return bankingService.buscarCliente(cpf);
    }
}
