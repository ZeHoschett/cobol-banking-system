package com.cb7bank.api.controller;

import com.cb7bank.api.dto.ContaResponse;
import com.cb7bank.api.dto.TransacaoResponse;
import com.cb7bank.api.service.BankingService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/contas")
public class ContaController {

    private final BankingService bankingService;

    public ContaController(BankingService bankingService) {
        this.bankingService = bankingService;
    }

    @GetMapping("/{numeroConta}")
    public ContaResponse buscarPorNumero(@PathVariable String numeroConta) {
        return bankingService.buscarConta(numeroConta);
    }

    @GetMapping("/{numeroConta}/extrato")
    public List<TransacaoResponse> buscarExtrato(@PathVariable String numeroConta) {
        return bankingService.buscarExtrato(numeroConta);
    }
}
