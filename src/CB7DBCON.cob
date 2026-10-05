       IDENTIFICATION DIVISION.
       PROGRAM-ID. CB7DBCON.

       DATA DIVISION.
       WORKING-STORAGE SECTION.

       EXEC SQL INCLUDE SQLCA END-EXEC.

       EXEC SQL BEGIN DECLARE SECTION END-EXEC.
       01 HV-CPF-IN          PIC X(11).
       01 HV-CPF-OUT         PIC X(11).
       01 HV-NOME            PIC X(150).
       01 HV-EMAIL           PIC X(160).
       01 HV-TELEFONE        PIC X(20).
       01 HV-IND-TELEFONE    PIC S9(4) COMP-5.
       EXEC SQL END DECLARE SECTION END-EXEC.

       PROCEDURE DIVISION.
       INICIO.
           DISPLAY "Digite o CPF (11 digitos): "
           ACCEPT HV-CPF-IN

           EXEC SQL
               SELECT CPF,
                      NOME_COMPLETO,
                      EMAIL,
                      TELEFONE
                 INTO :HV-CPF-OUT,
                      :HV-NOME,
                      :HV-EMAIL,
                      :HV-TELEFONE :HV-IND-TELEFONE
                 FROM CLIENTES
                WHERE CPF = :HV-CPF-IN
           END-EXEC

           EVALUATE TRUE
               WHEN SQLCODE = 0
                   DISPLAY "Cliente encontrado:"
                   DISPLAY "CPF:      " HV-CPF-OUT
                   DISPLAY "Nome:     " HV-NOME
                   DISPLAY "Email:    " HV-EMAIL
                   IF HV-IND-TELEFONE < 0
                       DISPLAY "Telefone: Nao informado"
                   ELSE
                       DISPLAY "Telefone: " HV-TELEFONE
                   END-IF
               WHEN SQLCODE = 100
                   DISPLAY "Cliente nao encontrado"
               WHEN SQLCODE < 0
                   DISPLAY "Erro no banco"
                   DISPLAY "SQLCODE: " SQLCODE
               WHEN OTHER
                   DISPLAY "Aviso do banco"
                   DISPLAY "SQLCODE: " SQLCODE
           END-EVALUATE

           STOP RUN.
