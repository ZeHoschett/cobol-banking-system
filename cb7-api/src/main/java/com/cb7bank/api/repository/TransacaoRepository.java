package com.cb7bank.api.repository;

import com.cb7bank.api.entity.Transacao;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface TransacaoRepository extends JpaRepository<Transacao, Long> {

    @Query("""
            select t from Transacao t
            left join fetch t.contaOrigem origem
            left join fetch t.contaDestino destino
            where origem.id = :contaId or destino.id = :contaId
            order by t.criadoEm desc, t.id desc
            """)
    List<Transacao> findExtratoByContaId(@Param("contaId") Long contaId);
}
