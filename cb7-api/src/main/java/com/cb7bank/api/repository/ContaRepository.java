package com.cb7bank.api.repository;

import com.cb7bank.api.entity.Conta;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ContaRepository extends JpaRepository<Conta, Long> {

    @Query("select c from Conta c join fetch c.cliente where c.numeroConta = :numeroConta and c.agencia = '0001'")
    Optional<Conta> findContaComCliente(@Param("numeroConta") String numeroConta);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select c from Conta c where c.numeroConta = :numeroConta and c.agencia = '0001'")
    Optional<Conta> findByNumeroContaForUpdate(@Param("numeroConta") String numeroConta);

    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select c from Conta c where c.id = :id")
    Optional<Conta> findByIdForUpdate(@Param("id") Long id);
}
