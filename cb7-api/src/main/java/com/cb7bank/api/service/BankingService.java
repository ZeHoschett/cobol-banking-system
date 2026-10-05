package com.cb7bank.api.service;

import com.cb7bank.api.dto.ClienteResponse;
import com.cb7bank.api.dto.ContaResponse;
import com.cb7bank.api.dto.OperacaoResponse;
import com.cb7bank.api.dto.TransacaoResponse;
import com.cb7bank.api.entity.Cliente;
import com.cb7bank.api.entity.Conta;
import com.cb7bank.api.entity.Transacao;
import com.cb7bank.api.exception.RecursoNaoEncontradoException;
import com.cb7bank.api.exception.RegraNegocioException;
import com.cb7bank.api.repository.ClienteRepository;
import com.cb7bank.api.repository.ContaRepository;
import com.cb7bank.api.repository.TransacaoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;

@Service
public class BankingService {

    private static final BigDecimal SALDO_MAXIMO = new BigDecimal("9999999999999.99");

    private final ClienteRepository clienteRepository;
    private final ContaRepository contaRepository;
    private final TransacaoRepository transacaoRepository;

    public BankingService(
            ClienteRepository clienteRepository,
            ContaRepository contaRepository,
            TransacaoRepository transacaoRepository
    ) {
        this.clienteRepository = clienteRepository;
        this.contaRepository = contaRepository;
        this.transacaoRepository = transacaoRepository;
    }

    @Transactional(readOnly = true)
    public ClienteResponse buscarCliente(String cpf) {
        Cliente cliente = clienteRepository.findByCpf(cpf)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Cliente não encontrado"));
        return new ClienteResponse(
                cliente.getCpf().trim(),
                cliente.getNomeCompleto(),
                cliente.getEmail(),
                cliente.getTelefone(),
                cliente.getDataNascimento(),
                cliente.getStatus()
        );
    }

    @Transactional(readOnly = true)
    public ContaResponse buscarConta(String numeroConta) {
        Conta conta = contaRepository.findContaComCliente(numeroConta)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta não encontrada"));
        return toContaResponse(conta);
    }

    @Transactional(readOnly = true)
    public List<TransacaoResponse> buscarExtrato(String numeroConta) {
        Conta conta = contaRepository.findContaComCliente(numeroConta)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta não encontrada"));
        return transacaoRepository.findExtratoByContaId(conta.getId()).stream()
                .map(this::toTransacaoResponse)
                .toList();
    }

    @Transactional
    public OperacaoResponse depositar(String numeroConta, BigDecimal valor) {
        validarValor(valor);
        Conta conta = contaRepository.findByNumeroContaForUpdate(numeroConta)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta não encontrada"));

        BigDecimal novoSaldo = validarSaldo(conta.getSaldo().add(valor));
        conta.setSaldo(novoSaldo);
        Transacao transacao = transacaoRepository.save(
                new Transacao(null, conta, "DEPOSITO", valor, "Depósito via API")
        );
        return OperacaoResponse.aprovada(transacao.getId(), novoSaldo);
    }

    @Transactional
    public OperacaoResponse sacar(String numeroConta, BigDecimal valor) {
        validarValor(valor);
        Conta conta = contaRepository.findByNumeroContaForUpdate(numeroConta)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta não encontrada"));

        if (conta.getSaldo().compareTo(valor) < 0) {
            throw new RegraNegocioException("Saldo insuficiente");
        }

        BigDecimal novoSaldo = conta.getSaldo().subtract(valor);
        conta.setSaldo(novoSaldo);
        Transacao transacao = transacaoRepository.save(
                new Transacao(conta, null, "SAQUE", valor, "Saque via API")
        );
        return OperacaoResponse.aprovada(transacao.getId(), novoSaldo);
    }

    @Transactional
    public OperacaoResponse transferir(String contaOrigemNumero, String contaDestinoNumero, BigDecimal valor) {
        validarValor(valor);
        if (contaOrigemNumero.equals(contaDestinoNumero)) {
            throw new RegraNegocioException("Conta destino deve ser diferente da conta origem");
        }

        Conta origemEncontrada = contaRepository.findContaComCliente(contaOrigemNumero)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta origem não encontrada"));
        Conta destinoEncontrada = contaRepository.findContaComCliente(contaDestinoNumero)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta destino não encontrada"));

        Long primeiroId = Math.min(origemEncontrada.getId(), destinoEncontrada.getId());
        Long segundoId = Math.max(origemEncontrada.getId(), destinoEncontrada.getId());
        Conta primeiraConta = contaRepository.findByIdForUpdate(primeiroId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta não encontrada"));
        Conta segundaConta = contaRepository.findByIdForUpdate(segundoId)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Conta não encontrada"));
        Conta origem = origemEncontrada.getId().equals(primeiroId) ? primeiraConta : segundaConta;
        Conta destino = destinoEncontrada.getId().equals(primeiroId) ? primeiraConta : segundaConta;

        if (origem.getSaldo().compareTo(valor) < 0) {
            throw new RegraNegocioException("Saldo insuficiente");
        }

        BigDecimal novoSaldoDestino = validarSaldo(destino.getSaldo().add(valor));
        BigDecimal novoSaldoOrigem = origem.getSaldo().subtract(valor);
        origem.setSaldo(novoSaldoOrigem);
        destino.setSaldo(novoSaldoDestino);
        Transacao transacao = transacaoRepository.save(
                new Transacao(origem, destino, "TRANSFERENCIA", valor, "Transferência via API")
        );
        return OperacaoResponse.aprovada(transacao.getId(), novoSaldoOrigem);
    }

    private void validarValor(BigDecimal valor) {
        if (valor == null || valor.compareTo(BigDecimal.ZERO) <= 0) {
            throw new RegraNegocioException("Valor deve ser maior que zero");
        }
    }

    private BigDecimal validarSaldo(BigDecimal saldo) {
        if (saldo.compareTo(SALDO_MAXIMO) > 0) {
            throw new RegraNegocioException("Saldo excede o limite suportado pela conta");
        }
        return saldo;
    }

    private ContaResponse toContaResponse(Conta conta) {
        return new ContaResponse(
                conta.getNumeroConta().trim(),
                conta.getAgencia().trim(),
                conta.getTipo(),
                conta.getSaldo(),
                conta.getLimite(),
                conta.getStatus(),
                conta.getCliente().getNomeCompleto()
        );
    }

    private TransacaoResponse toTransacaoResponse(Transacao transacao) {
        return new TransacaoResponse(
                transacao.getId(),
                transacao.getTipo(),
                transacao.getValor(),
                transacao.getDescricao(),
                transacao.getStatus(),
                transacao.getCriadoEm(),
                transacao.getContaOrigem() == null ? null : transacao.getContaOrigem().getNumeroConta().trim(),
                transacao.getContaDestino() == null ? null : transacao.getContaDestino().getNumeroConta().trim()
        );
    }
}
