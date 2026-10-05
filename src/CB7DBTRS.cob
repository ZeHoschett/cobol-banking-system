       IDENTIFICATION DIVISION.
       PROGRAM-ID. CB7DBTRS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQUIVO-TRANSACOES
               ASSIGN TO "TRANSACOES.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-ARQUIVO.

       DATA DIVISION.
       FILE SECTION.
       FD ARQUIVO-TRANSACOES.
       01 REGISTRO-TRANSACAO.
          05 FD-CONTA-ORIGEM  PIC X(10).
          05 FD-TIPO          PIC 9.
          05 FD-VALOR         PIC 9(11)V99.
          05 FD-CONTA-DESTINO PIC X(10).

       WORKING-STORAGE SECTION.
       EXEC SQL INCLUDE SQLCA END-EXEC.

       01 WS-STATUS-ARQUIVO PIC XX.
       01 WS-FIM-ARQUIVO    PIC X VALUE "N".
       01 WS-ERRO-FATAL     PIC X VALUE "N".
       01 WS-PODE-PROCESSAR PIC X VALUE "N".
       01 WS-APROVADA       PIC X VALUE "N".
       01 WS-MOTIVO         PIC X(40).
       01 WS-TIPO-TEXTO     PIC X(20).
       01 WS-SQLCODE-ERRO   PIC S9(9) COMP-5.

       01 WS-TOTAL          PIC 9(9) COMP-5 VALUE 0.
       01 WS-APROVADAS      PIC 9(9) COMP-5 VALUE 0.
       01 WS-REJEITADAS     PIC 9(9) COMP-5 VALUE 0.
       01 WS-TOTAL-EDIT     PIC Z(8)9.
       01 WS-APROV-EDIT     PIC Z(8)9.
       01 WS-REJ-EDIT       PIC Z(8)9.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 HV-AGENCIA        PIC X(4).
       01 HV-CONTA          PIC X(12).
       01 HV-CONTA-DESTINO  PIC X(12).
       01 HV-ID-ORIGEM      PIC S9(18) COMP-5.
       01 HV-ID-DESTINO     PIC S9(18) COMP-5.
       01 HV-SALDO-ORIGEM   PIC S9(15)V99 COMP-3.
       01 HV-SALDO-DESTINO  PIC S9(15)V99 COMP-3.
       01 HV-VALOR          PIC S9(11)V99 COMP-3.
       01 HV-TIPO-TEXTO     PIC X(20).
       01 HV-DESCRICAO      PIC X(255).
       01 HV-INSERT-ORIGEM  PIC S9(18) COMP-5.
       01 HV-INSERT-DESTINO PIC S9(18) COMP-5.
       01 HV-IND-ORIGEM     PIC S9(4) COMP-5.
       01 HV-IND-DESTINO    PIC S9(4) COMP-5.
       EXEC SQL END DECLARE SECTION END-EXEC.

       PROCEDURE DIVISION.
       INICIO.
           MOVE "0001" TO HV-AGENCIA
           OPEN INPUT ARQUIVO-TRANSACOES

           IF WS-STATUS-ARQUIVO NOT = "00"
               DISPLAY "Erro ao abrir TRANSACOES.dat. Status: "
                   WS-STATUS-ARQUIVO
               MOVE "S" TO WS-ERRO-FATAL
           ELSE
               PERFORM UNTIL WS-FIM-ARQUIVO = "S"
                   OR WS-ERRO-FATAL = "S"
                   READ ARQUIVO-TRANSACOES
                       AT END
                           MOVE "S" TO WS-FIM-ARQUIVO
                       NOT AT END
                           ADD 1 TO WS-TOTAL
                           PERFORM PROCESSAR-TRANSACAO
                           IF WS-APROVADA = "S"
                               ADD 1 TO WS-APROVADAS
                           ELSE
                               ADD 1 TO WS-REJEITADAS
                           END-IF
                   END-READ

                   IF WS-FIM-ARQUIVO NOT = "S"
                       AND WS-STATUS-ARQUIVO NOT = "00"
                       AND WS-STATUS-ARQUIVO NOT = "10"
                       DISPLAY "Erro ao ler TRANSACOES.dat. Status: "
                           WS-STATUS-ARQUIVO
                       MOVE "S" TO WS-ERRO-FATAL
                   END-IF
               END-PERFORM

               CLOSE ARQUIVO-TRANSACOES
               IF WS-STATUS-ARQUIVO NOT = "00"
                   DISPLAY "Erro ao fechar TRANSACOES.dat. Status: "
                       WS-STATUS-ARQUIVO
                   MOVE "S" TO WS-ERRO-FATAL
               END-IF
           END-IF

           PERFORM EXIBIR-RESUMO
           STOP RUN.

       PROCESSAR-TRANSACAO.
           MOVE "N" TO WS-APROVADA
           MOVE "S" TO WS-PODE-PROCESSAR
           MOVE SPACES TO WS-MOTIVO
           MOVE SPACES TO WS-TIPO-TEXTO
           MOVE FD-VALOR TO HV-VALOR

           EVALUATE FD-TIPO
               WHEN 1
                   MOVE "DEPOSITO" TO WS-TIPO-TEXTO
               WHEN 2
                   MOVE "SAQUE" TO WS-TIPO-TEXTO
               WHEN 3
                   MOVE "TRANSFERENCIA" TO WS-TIPO-TEXTO
               WHEN OTHER
                   MOVE "Tipo de transacao invalido" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
           END-EVALUATE

           IF WS-PODE-PROCESSAR = "S"
               IF HV-VALOR <= 0
                   MOVE "Valor deve ser maior que zero" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               END-IF
           END-IF

           IF WS-PODE-PROCESSAR = "S"
               PERFORM BUSCAR-CONTA-ORIGEM
           END-IF

           IF WS-PODE-PROCESSAR = "S"
               EVALUATE FD-TIPO
                   WHEN 1
                       PERFORM PROCESSAR-DEPOSITO
                   WHEN 2
                       PERFORM PROCESSAR-SAQUE
                   WHEN 3
                       PERFORM PROCESSAR-TRANSFERENCIA
               END-EVALUATE
           END-IF

           IF WS-APROVADA = "N"
               DISPLAY "Transacao rejeitada. Motivo: "
                   FUNCTION TRIM(WS-MOTIVO)
           ELSE
               DISPLAY "Transacao aprovada."
           END-IF.

       BUSCAR-CONTA-ORIGEM.
           MOVE FD-CONTA-ORIGEM TO HV-CONTA

           EXEC SQL
               SELECT ID, SALDO
                 INTO :HV-ID-ORIGEM, :HV-SALDO-ORIGEM
                 FROM CONTAS
                WHERE AGENCIA = :HV-AGENCIA
                  AND NUMERO_CONTA = :HV-CONTA
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN 100
                   MOVE "Conta origem nao encontrada" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               WHEN OTHER
                   PERFORM TRATAR-ERRO-SQL
           END-EVALUATE.

       BUSCAR-CONTA-DESTINO.
           MOVE FD-CONTA-DESTINO TO HV-CONTA-DESTINO

           EXEC SQL
               SELECT ID, SALDO
                 INTO :HV-ID-DESTINO, :HV-SALDO-DESTINO
                 FROM CONTAS
                WHERE AGENCIA = :HV-AGENCIA
                  AND NUMERO_CONTA = :HV-CONTA-DESTINO
           END-EXEC

           EVALUATE SQLCODE
               WHEN 0
                   CONTINUE
               WHEN 100
                   MOVE "Conta destino nao encontrada" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               WHEN OTHER
                   PERFORM TRATAR-ERRO-SQL
           END-EVALUATE.

       PROCESSAR-DEPOSITO.
           MOVE "Deposito processado via CB7DBTRS"
               TO HV-DESCRICAO

           EXEC SQL
               UPDATE CONTAS
                  SET SALDO = SALDO + :HV-VALOR
                WHERE ID = :HV-ID-ORIGEM
           END-EXEC

           IF SQLCODE NOT = 0
               PERFORM TRATAR-ERRO-SQL
           ELSE
               IF SQLERRD(3) NOT = 1
                   MOVE "Conta nao atualizada" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               ELSE
                   PERFORM GRAVAR-TRANSACAO
               END-IF
           END-IF.

       PROCESSAR-SAQUE.
           MOVE "Saque processado via CB7DBTRS"
               TO HV-DESCRICAO

           EXEC SQL
               UPDATE CONTAS
                  SET SALDO = SALDO - :HV-VALOR
                WHERE ID = :HV-ID-ORIGEM
                  AND SALDO >= :HV-VALOR
           END-EXEC

           IF SQLCODE NOT = 0
               PERFORM TRATAR-ERRO-SQL
           ELSE
               IF SQLERRD(3) NOT = 1
                   MOVE "Saldo insuficiente" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               ELSE
                   PERFORM GRAVAR-TRANSACAO
               END-IF
           END-IF.

       PROCESSAR-TRANSFERENCIA.
           PERFORM BUSCAR-CONTA-DESTINO

           IF WS-PODE-PROCESSAR = "S"
               IF HV-ID-ORIGEM = HV-ID-DESTINO
                   MOVE "Conta destino igual a origem" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               END-IF
           END-IF

           IF WS-PODE-PROCESSAR = "S"
               MOVE "Transferencia processada via CB7DBTRS"
                   TO HV-DESCRICAO

               EXEC SQL
                   UPDATE CONTAS
                      SET SALDO = SALDO - :HV-VALOR
                    WHERE ID = :HV-ID-ORIGEM
                      AND SALDO >= :HV-VALOR
               END-EXEC

               IF SQLCODE NOT = 0
                   PERFORM TRATAR-ERRO-SQL
               ELSE
                   IF SQLERRD(3) NOT = 1
                       MOVE "Saldo insuficiente" TO WS-MOTIVO
                       PERFORM REJEITAR-TRANSACAO
                   ELSE
                       PERFORM CREDITAR-CONTA-DESTINO
                   END-IF
               END-IF
           END-IF.

       CREDITAR-CONTA-DESTINO.
           EXEC SQL
               UPDATE CONTAS
                  SET SALDO = SALDO + :HV-VALOR
                WHERE ID = :HV-ID-DESTINO
           END-EXEC

           IF SQLCODE NOT = 0
               PERFORM TRATAR-ERRO-SQL
           ELSE
               IF SQLERRD(3) NOT = 1
                   MOVE "Conta destino nao atualizada" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               ELSE
                   PERFORM GRAVAR-TRANSACAO
               END-IF
           END-IF.

       GRAVAR-TRANSACAO.
           MOVE WS-TIPO-TEXTO TO HV-TIPO-TEXTO

           EVALUATE FD-TIPO
               WHEN 1
                   MOVE -1 TO HV-IND-ORIGEM
                   MOVE HV-ID-ORIGEM TO HV-INSERT-DESTINO
                   MOVE 0 TO HV-IND-DESTINO
               WHEN 2
                   MOVE HV-ID-ORIGEM TO HV-INSERT-ORIGEM
                   MOVE 0 TO HV-IND-ORIGEM
                   MOVE -1 TO HV-IND-DESTINO
               WHEN 3
                   MOVE HV-ID-ORIGEM TO HV-INSERT-ORIGEM
                   MOVE 0 TO HV-IND-ORIGEM
                   MOVE HV-ID-DESTINO TO HV-INSERT-DESTINO
                   MOVE 0 TO HV-IND-DESTINO
           END-EVALUATE

           EXEC SQL
               INSERT INTO TRANSACOES
                   (CONTA_ORIGEM_ID, CONTA_DESTINO_ID, TIPO,
                    VALOR, DESCRICAO, STATUS)
               VALUES
                   (:HV-INSERT-ORIGEM :HV-IND-ORIGEM,
                    :HV-INSERT-DESTINO :HV-IND-DESTINO,
                    :HV-TIPO-TEXTO, :HV-VALOR, :HV-DESCRICAO,
                    'CONCLUIDA')
           END-EXEC

           IF SQLCODE NOT = 0
               PERFORM TRATAR-ERRO-SQL
           ELSE
               IF SQLERRD(3) NOT = 1
                   MOVE "Transacao nao gravada" TO WS-MOTIVO
                   PERFORM REJEITAR-TRANSACAO
               ELSE
                   EXEC SQL COMMIT END-EXEC
                   IF SQLCODE = 0
                       MOVE "S" TO WS-APROVADA
                   ELSE
                       PERFORM TRATAR-ERRO-SQL
                   END-IF
               END-IF
           END-IF.

       REJEITAR-TRANSACAO.
           MOVE "N" TO WS-PODE-PROCESSAR
           EXEC SQL ROLLBACK END-EXEC
           IF SQLCODE NOT = 0
               DISPLAY "Erro no ROLLBACK. SQLCODE: " SQLCODE
               MOVE "S" TO WS-ERRO-FATAL
           END-IF.

       TRATAR-ERRO-SQL.
           MOVE SQLCODE TO WS-SQLCODE-ERRO
           DISPLAY "Erro no banco. SQLCODE: " WS-SQLCODE-ERRO
           MOVE "Erro ao processar no banco" TO WS-MOTIVO
           MOVE "N" TO WS-PODE-PROCESSAR
           MOVE "S" TO WS-ERRO-FATAL
           EXEC SQL ROLLBACK END-EXEC
           IF SQLCODE NOT = 0
               DISPLAY "Erro no ROLLBACK. SQLCODE: " SQLCODE
           END-IF.

       EXIBIR-RESUMO.
           MOVE WS-TOTAL TO WS-TOTAL-EDIT
           MOVE WS-APROVADAS TO WS-APROV-EDIT
           MOVE WS-REJEITADAS TO WS-REJ-EDIT

           DISPLAY " "
           DISPLAY "RESUMO DO PROCESSAMENTO"
           DISPLAY "Total:       " WS-TOTAL-EDIT
           DISPLAY "Aprovadas:   " WS-APROV-EDIT
           DISPLAY "Rejeitadas:  " WS-REJ-EDIT
           IF WS-ERRO-FATAL = "S"
               DISPLAY "Processamento interrompido por erro."
           END-IF.
