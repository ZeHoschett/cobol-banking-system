package com.cb7bank.api.service;

import com.cb7bank.api.entity.Conta;
import com.cb7bank.api.entity.Transacao;
import com.cb7bank.api.exception.RegraNegocioException;
import com.cb7bank.api.repository.ClienteRepository;
import com.cb7bank.api.repository.ContaRepository;
import com.cb7bank.api.repository.TransacaoRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class BankingServiceTest {

    @Mock
    private ClienteRepository clienteRepository;

    @Mock
    private ContaRepository contaRepository;

    @Mock
    private TransacaoRepository transacaoRepository;

    @InjectMocks
    private BankingService bankingService;

    @Test
    void saqueComSaldoInsuficienteEhNegadoSemRegistrarTransacao() {
        Conta conta = contaComSaldo("100.00");
        when(contaRepository.findByNumeroContaForUpdate("000000012345"))
                .thenReturn(Optional.of(conta));

        RegraNegocioException exception = assertThrows(
                RegraNegocioException.class,
                () -> bankingService.sacar("000000012345", new BigDecimal("100.01"))
        );

        assertEquals("Saldo insuficiente", exception.getMessage());
        verify(transacaoRepository, never()).save(any(Transacao.class));
    }

    @Test
    void depositoAtualizaSaldoEGravaTransacao() {
        Conta conta = contaComSaldo("100.00");
        Transacao transacao = mock(Transacao.class);
        when(transacao.getId()).thenReturn(1L);
        when(contaRepository.findByNumeroContaForUpdate("000000012345"))
                .thenReturn(Optional.of(conta));
        when(transacaoRepository.save(any(Transacao.class))).thenReturn(transacao);

        bankingService.depositar("000000012345", new BigDecimal("50.00"));

        verify(conta).setSaldo(new BigDecimal("150.00"));
        verify(transacaoRepository).save(any(Transacao.class));
    }

    private Conta contaComSaldo(String saldo) {
        Conta conta = mock(Conta.class);
        when(conta.getSaldo()).thenReturn(new BigDecimal(saldo));
        return conta;
    }
}
