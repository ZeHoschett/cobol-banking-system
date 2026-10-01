       IDENTIFICATION DIVISION.
       PROGRAM-ID. LER-CONTAS.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQUIVO-CONTAS
               ASSIGN TO "CONTAS.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-ARQUIVO.

       DATA DIVISION.
       FILE SECTION.
       FD ARQUIVO-CONTAS.
       01 REGISTRO-CONTA.
          05 FD-NUMERO-CONTA PIC X(10).
          05 FD-AGENCIA      PIC X(4).
          05 FD-TIPO-CONTA  PIC X(10).
          05 FD-SALDO       PIC 9(11)V99.
          05 FD-CPF         PIC X(11).

       WORKING-STORAGE SECTION.
       01 WS-STATUS-ARQUIVO PIC XX.
       01 WS-FIM-ARQUIVO    PIC X VALUE "N".
       01 WS-SALDO-EXIBICAO PIC Z(10)9.99.

       PROCEDURE DIVISION.
       INICIO.
           OPEN INPUT ARQUIVO-CONTAS

           IF WS-STATUS-ARQUIVO NOT = "00"
               DISPLAY "Erro ao abrir CONTAS.dat. Status: "
                   WS-STATUS-ARQUIVO
           ELSE
               DISPLAY "REGISTROS DE CONTAS"
               DISPLAY "--------------------"

               PERFORM UNTIL WS-FIM-ARQUIVO = "S"
                   READ ARQUIVO-CONTAS
                       AT END
                           MOVE "S" TO WS-FIM-ARQUIVO
                       NOT AT END
                           PERFORM EXIBIR-CONTA
                   END-READ

                   IF WS-STATUS-ARQUIVO = "06"
                       MOVE "S" TO WS-FIM-ARQUIVO
                   ELSE
                       IF WS-FIM-ARQUIVO NOT = "S"
                           AND WS-STATUS-ARQUIVO NOT = "00"
                           AND WS-STATUS-ARQUIVO NOT = "10"
                           DISPLAY "Erro de leitura. Status: "
                               WS-STATUS-ARQUIVO
                           MOVE "S" TO WS-FIM-ARQUIVO
                       END-IF
                   END-IF
               END-PERFORM

               CLOSE ARQUIVO-CONTAS

               IF WS-STATUS-ARQUIVO NOT = "00"
                   DISPLAY "Erro ao fechar arquivo. Status: "
                       WS-STATUS-ARQUIVO
               END-IF
           END-IF

           STOP RUN.

       EXIBIR-CONTA.
           MOVE FD-SALDO TO WS-SALDO-EXIBICAO
           DISPLAY "Numero:    " FUNCTION TRIM(FD-NUMERO-CONTA)
           DISPLAY "Agencia:   " FUNCTION TRIM(FD-AGENCIA)
           DISPLAY "Tipo:      " FUNCTION TRIM(FD-TIPO-CONTA)
           DISPLAY "Saldo:     " WS-SALDO-EXIBICAO
           DISPLAY "CPF:       " FUNCTION TRIM(FD-CPF)
           DISPLAY "--------------------".
