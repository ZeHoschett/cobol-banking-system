       IDENTIFICATION DIVISION.
       PROGRAM-ID. LER-TRANSACOES.

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
       01 WS-STATUS-ARQUIVO  PIC XX.
       01 WS-FIM-ARQUIVO     PIC X VALUE "N".
       01 WS-TIPO-TEXTO      PIC X(15).
       01 WS-VALOR-EXIBICAO  PIC Z(10)9.99.

       PROCEDURE DIVISION.
       INICIO.
           OPEN INPUT ARQUIVO-TRANSACOES

           IF WS-STATUS-ARQUIVO NOT = "00"
               DISPLAY "Erro ao abrir TRANSACOES.dat. Status: "
                   WS-STATUS-ARQUIVO
           ELSE
               DISPLAY "REGISTROS DE TRANSACOES"
               DISPLAY "------------------------"

               PERFORM UNTIL WS-FIM-ARQUIVO = "S"
                   READ ARQUIVO-TRANSACOES
                       AT END
                           MOVE "S" TO WS-FIM-ARQUIVO
                       NOT AT END
                           PERFORM EXIBIR-TRANSACAO
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

               CLOSE ARQUIVO-TRANSACOES

               IF WS-STATUS-ARQUIVO NOT = "00"
                   DISPLAY "Erro ao fechar arquivo. Status: "
                       WS-STATUS-ARQUIVO
               END-IF
           END-IF

           STOP RUN.

       EXIBIR-TRANSACAO.
           EVALUATE FD-TIPO
               WHEN 1
                   MOVE "DEPOSITO" TO WS-TIPO-TEXTO
               WHEN 2
                   MOVE "SAQUE" TO WS-TIPO-TEXTO
               WHEN 3
                   MOVE "TRANSFERENCIA" TO WS-TIPO-TEXTO
               WHEN OTHER
                   MOVE "TIPO INVALIDO" TO WS-TIPO-TEXTO
           END-EVALUATE

           MOVE FD-VALOR TO WS-VALOR-EXIBICAO
           DISPLAY "Conta origem:  "
               FUNCTION TRIM(FD-CONTA-ORIGEM)
           DISPLAY "Tipo:          "
               FUNCTION TRIM(WS-TIPO-TEXTO)
           DISPLAY "Valor:         " WS-VALOR-EXIBICAO
           DISPLAY "Conta destino: "
               FUNCTION TRIM(FD-CONTA-DESTINO)
           DISPLAY "------------------------".
