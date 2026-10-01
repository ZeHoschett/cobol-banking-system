       IDENTIFICATION DIVISION.
       PROGRAM-ID. LER-CLIENTES.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQUIVO-CLIENTES
               ASSIGN TO "CLIENTES.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-ARQUIVO.

       DATA DIVISION.
       FILE SECTION.
       FD ARQUIVO-CLIENTES.
       01 REGISTRO-CLIENTE.
          05 FD-CPF       PIC X(11).
          05 FD-NOME      PIC X(40).
          05 FD-TELEFONE  PIC X(11).
          05 FD-EMAIL     PIC X(30).

       WORKING-STORAGE SECTION.
       01 WS-STATUS-ARQUIVO PIC XX.
       01 WS-FIM-ARQUIVO    PIC X VALUE "N".

       PROCEDURE DIVISION.
       INICIO.
           OPEN INPUT ARQUIVO-CLIENTES

           IF WS-STATUS-ARQUIVO NOT = "00"
               DISPLAY "Erro ao abrir CLIENTES.dat. Status: "
                   WS-STATUS-ARQUIVO
           ELSE
               DISPLAY "REGISTROS DE CLIENTES"
               DISPLAY "---------------------"

               PERFORM UNTIL WS-FIM-ARQUIVO = "S"
                   READ ARQUIVO-CLIENTES
                       AT END
                           MOVE "S" TO WS-FIM-ARQUIVO
                       NOT AT END
                           PERFORM EXIBIR-CLIENTE
                   END-READ

                   IF WS-STATUS-ARQUIVO NOT = "00"
                       AND WS-STATUS-ARQUIVO NOT = "10"
                       DISPLAY "Erro de leitura. Status: "
                           WS-STATUS-ARQUIVO
                       MOVE "S" TO WS-FIM-ARQUIVO
                   END-IF
               END-PERFORM

               CLOSE ARQUIVO-CLIENTES

               IF WS-STATUS-ARQUIVO NOT = "00"
                   DISPLAY "Erro ao fechar arquivo. Status: "
                       WS-STATUS-ARQUIVO
               END-IF
           END-IF

           STOP RUN.

       EXIBIR-CLIENTE.
           DISPLAY "CPF:       " FUNCTION TRIM(FD-CPF)
           DISPLAY "Nome:      " FUNCTION TRIM(FD-NOME)
           DISPLAY "Telefone:  " FUNCTION TRIM(FD-TELEFONE)
           DISPLAY "Email:     " FUNCTION TRIM(FD-EMAIL)
           DISPLAY "---------------------".
