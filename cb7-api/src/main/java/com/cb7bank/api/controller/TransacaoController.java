package com.cb7bank.api.controller;

import com.cb7bank.api.dto.DepositoRequest;
import com.cb7bank.api.dto.OperacaoResponse;
import com.cb7bank.api.dto.SaqueRequest;
import com.cb7bank.api.dto.TransferenciaRequest;
import com.cb7bank.api.service.BankingService;
import jakarta.validation.Valid;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/transacoes")
public class TransacaoController {

    private final BankingService bankingService;

    public TransacaoController(BankingService bankingService) {
        this.bankingService = bankingService;
    }

    @PostMapping("/deposito")
    public OperacaoResponse depositar(@Valid @RequestBody DepositoRequest request) {
        return bankingService.depositar(request.conta(), request.valor());
    }

    @PostMapping("/saque")
    public OperacaoResponse sacar(@Valid @RequestBody SaqueRequest request) {
        return bankingService.sacar(request.conta(), request.valor());
    }

    @PostMapping("/transferencia")
    public OperacaoResponse transferir(@Valid @RequestBody TransferenciaRequest request) {
        return bankingService.transferir(request.contaOrigem(), request.contaDestino(), request.valor());
    }
}
