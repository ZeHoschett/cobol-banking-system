       IDENTIFICATION DIVISION.
       PROGRAM-ID. CB7-BANK.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01 WS-TABELA-CLIENTES.
          05 WS-CLIENTE OCCURS 3 TIMES.
             10 WS-CLIENTE-NOME PIC X(40).
             10 WS-CLIENTE-CPF  PIC X(11).

       01 WS-TABELA-CONTAS.
          05 WS-CONTA OCCURS 3 TIMES.
             10 WS-CONTA-NUMERO  PIC X(10).
             10 WS-CONTA-AGENCIA PIC X(4).
             10 WS-CONTA-TIPO    PIC X(10).
             10 WS-CONTA-SALDO   PIC 9(9)V99.
             10 WS-CONTA-CPF     PIC X(11).

       01 WS-CPF-ENTRADA          PIC X(11).
       01 WS-CONTA-ENTRADA        PIC X(10).
       01 WS-INDICE-CLIENTE       PIC 9 VALUE 0.
       01 WS-INDICE-CLIENTE-LOOP  PIC 9 VALUE 0.
       01 WS-INDICE-CONTA         PIC 9 VALUE 0.
       01 WS-INDICE-CONTA-LOOP    PIC 9 VALUE 0.
         01 WS-INDICE-DESTINO       PIC 9 VALUE 0.
         01 WS-INDICE-DESTINO-LOOP  PIC 9 VALUE 0.
       01 WS-CLIENTE-ENCONTRADO   PIC 9 VALUE 0.
       01 WS-CONTA-ENCONTRADA     PIC 9 VALUE 0.
         01 WS-DESTINO-ENCONTRADO   PIC X VALUE "N".
         01 WS-DESTINO-VALIDO       PIC X VALUE "N".
       01 WS-QTD-CONTAS           PIC 9 VALUE 0.

       01 WS-TRANSACAO            PIC 9.
       01 WS-VALOR-TEXTO          PIC X(20).
       01 WS-VALOR                PIC S9(9)V99.
       01 WS-VALOR-VALIDO         PIC X.
       01 WS-STATUS               PIC X(8).
       01 WS-MOTIVO               PIC X(40).
       01 WS-SALDO-EXIBICAO       PIC Z(8)9.99.
         01 WS-NOVO-SALDO-ORIGEM    PIC 9(9)V99.
         01 WS-NOVO-SALDO-DESTINO   PIC 9(9)V99.
         01 WS-CALCULOS-OK          PIC X.
       01 WS-CONTINUAR            PIC X.

       PROCEDURE DIVISION.
           PERFORM CARREGAR-DADOS

           MOVE "S" TO WS-CONTINUAR
           PERFORM UNTIL WS-CONTINUAR = "N"
               PERFORM PROCESSAR-TRANSACAO
               PERFORM PERGUNTAR-CONTINUACAO
           END-PERFORM

           DISPLAY "Programa encerrado."
           STOP RUN.

       CARREGAR-DADOS.
           MOVE "MARIA DA SILVA" TO WS-CLIENTE-NOME(1)
           MOVE "12345678901"    TO WS-CLIENTE-CPF(1)

           MOVE "JOAO PEREIRA"   TO WS-CLIENTE-NOME(2)
           MOVE "23456789012"    TO WS-CLIENTE-CPF(2)

           MOVE "ANA COSTA"      TO WS-CLIENTE-NOME(3)
           MOVE "34567890123"    TO WS-CLIENTE-CPF(3)

           MOVE "0001234567" TO WS-CONTA-NUMERO(1)
           MOVE "0001"       TO WS-CONTA-AGENCIA(1)
           MOVE "CORRENTE"   TO WS-CONTA-TIPO(1)
           MOVE 1500.00      TO WS-CONTA-SALDO(1)
           MOVE "12345678901" TO WS-CONTA-CPF(1)

           MOVE "0007654321" TO WS-CONTA-NUMERO(2)
           MOVE "0002"       TO WS-CONTA-AGENCIA(2)
           MOVE "POUPANCA"   TO WS-CONTA-TIPO(2)
           MOVE 2500.00      TO WS-CONTA-SALDO(2)
           MOVE "23456789012" TO WS-CONTA-CPF(2)

           MOVE "0009876543" TO WS-CONTA-NUMERO(3)
           MOVE "0003"       TO WS-CONTA-AGENCIA(3)
           MOVE "CORRENTE"   TO WS-CONTA-TIPO(3)
           MOVE 500.00       TO WS-CONTA-SALDO(3)
           MOVE "34567890123" TO WS-CONTA-CPF(3).

       PROCESSAR-TRANSACAO.
           MOVE "NEGADA" TO WS-STATUS
           MOVE SPACES TO WS-MOTIVO
           MOVE "N" TO WS-VALOR-VALIDO
           MOVE 0 TO WS-TRANSACAO
           MOVE 0 TO WS-INDICE-CLIENTE
           MOVE 0 TO WS-INDICE-CONTA
           MOVE 0 TO WS-INDICE-DESTINO
           MOVE 0 TO WS-CLIENTE-ENCONTRADO
           MOVE 0 TO WS-CONTA-ENCONTRADA
           MOVE "N" TO WS-DESTINO-ENCONTRADO
           MOVE "N" TO WS-DESTINO-VALIDO
           MOVE 0 TO WS-QTD-CONTAS

           DISPLAY "CPF do cliente (11 digitos, sem pontuacao): "
           ACCEPT WS-CPF-ENTRADA

           PERFORM VARYING WS-INDICE-CLIENTE-LOOP FROM 1 BY 1
               UNTIL WS-INDICE-CLIENTE-LOOP > 3
                   OR WS-CLIENTE-ENCONTRADO = 1
               IF WS-CLIENTE-CPF(WS-INDICE-CLIENTE-LOOP)
                   = WS-CPF-ENTRADA
                   MOVE WS-INDICE-CLIENTE-LOOP
                       TO WS-INDICE-CLIENTE
                   MOVE 1 TO WS-CLIENTE-ENCONTRADO
               END-IF
           END-PERFORM

           IF WS-CLIENTE-ENCONTRADO = 0
               MOVE "Cliente nao encontrado" TO WS-MOTIVO
           ELSE
               DISPLAY "Cliente: "
                   FUNCTION TRIM(
                       WS-CLIENTE-NOME(WS-INDICE-CLIENTE))
               DISPLAY "Contas vinculadas ao CPF:"

               PERFORM VARYING WS-INDICE-CONTA-LOOP FROM 1 BY 1
                   UNTIL WS-INDICE-CONTA-LOOP > 3
                   IF WS-CONTA-CPF(WS-INDICE-CONTA-LOOP)
                       = WS-CPF-ENTRADA
                       ADD 1 TO WS-QTD-CONTAS
                       DISPLAY "Conta: "
                           WS-CONTA-NUMERO(WS-INDICE-CONTA-LOOP)
                           " Agencia: "
                           WS-CONTA-AGENCIA(WS-INDICE-CONTA-LOOP)
                           " Tipo: "
                           FUNCTION TRIM(
                             WS-CONTA-TIPO(WS-INDICE-CONTA-LOOP))
                   END-IF
               END-PERFORM

               IF WS-QTD-CONTAS = 0
                   MOVE "Nenhuma conta vinculada ao cliente"
                       TO WS-MOTIVO
               ELSE
                   DISPLAY
                       "Numero da conta para a transacao: "
                   ACCEPT WS-CONTA-ENTRADA

                   PERFORM VARYING WS-INDICE-CONTA-LOOP FROM 1 BY 1
                       UNTIL WS-INDICE-CONTA-LOOP > 3
                           OR WS-CONTA-ENCONTRADA = 1
                       IF WS-CONTA-NUMERO(WS-INDICE-CONTA-LOOP)
                           = WS-CONTA-ENTRADA
                           AND WS-CONTA-CPF(WS-INDICE-CONTA-LOOP)
                           = WS-CPF-ENTRADA
                           MOVE WS-INDICE-CONTA-LOOP
                               TO WS-INDICE-CONTA
                           MOVE 1 TO WS-CONTA-ENCONTRADA
                       END-IF
                   END-PERFORM

                   IF WS-CONTA-ENCONTRADA = 0
                       MOVE "Conta nao encontrada para este CPF"
                           TO WS-MOTIVO
                   ELSE
                       PERFORM EXECUTAR-TRANSACAO
                   END-IF
               END-IF
           END-IF

           DISPLAY "Status: " FUNCTION TRIM(WS-STATUS)
           IF WS-STATUS = "NEGADA"
               DISPLAY "Motivo: " FUNCTION TRIM(WS-MOTIVO)
           END-IF

           IF WS-CONTA-ENCONTRADA = 1
               MOVE WS-CONTA-SALDO(WS-INDICE-CONTA)
                   TO WS-SALDO-EXIBICAO
               DISPLAY "Saldo atualizado: " WS-SALDO-EXIBICAO
           ELSE
               DISPLAY "Saldo atualizado: indisponivel"
           END-IF

           IF WS-TRANSACAO = 3
               AND WS-STATUS = "APROVADA"
               DISPLAY "Transferencia realizada para a conta: "
                   WS-CONTA-NUMERO(WS-INDICE-DESTINO)
           END-IF.

       EXECUTAR-TRANSACAO.
           DISPLAY "Transacao (1=Deposito, 2=Saque, 3=Transferencia): "
           ACCEPT WS-TRANSACAO

           IF WS-TRANSACAO < 1 OR WS-TRANSACAO > 3
               MOVE "Tipo de transacao invalido" TO WS-MOTIVO
           ELSE
               IF WS-TRANSACAO = 3
                   PERFORM LOCALIZAR-DESTINO
               END-IF

               IF WS-TRANSACAO NOT = 3
                   OR WS-DESTINO-VALIDO = "S"
                   PERFORM LER-VALOR-E-EXECUTAR
               END-IF
           END-IF.

       LOCALIZAR-DESTINO.
           DISPLAY "Numero da conta destino (10 caracteres): "
           ACCEPT WS-CONTA-ENTRADA

           PERFORM VARYING WS-INDICE-DESTINO-LOOP FROM 1 BY 1
               UNTIL WS-INDICE-DESTINO-LOOP > 3
                   OR WS-DESTINO-ENCONTRADO = "S"
               IF WS-CONTA-NUMERO(WS-INDICE-DESTINO-LOOP)
                   = WS-CONTA-ENTRADA
                   MOVE WS-INDICE-DESTINO-LOOP
                       TO WS-INDICE-DESTINO
                   MOVE "S" TO WS-DESTINO-ENCONTRADO
               END-IF
           END-PERFORM

           IF WS-DESTINO-ENCONTRADO = "N"
               MOVE "Conta destino nao encontrada" TO WS-MOTIVO
           ELSE
               IF WS-INDICE-DESTINO = WS-INDICE-CONTA
                   MOVE "Conta destino igual a origem" TO WS-MOTIVO
               ELSE
                   MOVE "S" TO WS-DESTINO-VALIDO
               END-IF
           END-IF.

       LER-VALOR-E-EXECUTAR.
           DISPLAY "Valor (use ponto para decimais, ex.: "
               "50.00): "
           ACCEPT WS-VALOR-TEXTO

           IF FUNCTION TEST-NUMVAL(
               FUNCTION TRIM(WS-VALOR-TEXTO)) NOT = 0
               MOVE "Valor invalido" TO WS-MOTIVO
           ELSE
               COMPUTE WS-VALOR =
                   FUNCTION NUMVAL(
                       FUNCTION TRIM(WS-VALOR-TEXTO))
                   ON SIZE ERROR
                       MOVE "Valor fora do limite permitido"
                           TO WS-MOTIVO
                   NOT ON SIZE ERROR
                       MOVE "S" TO WS-VALOR-VALIDO
               END-COMPUTE

               IF WS-VALOR-VALIDO = "S"
                   IF WS-VALOR <= 0
                       MOVE "Valor deve ser maior que zero"
                           TO WS-MOTIVO
                   ELSE
                       EVALUATE WS-TRANSACAO
                           WHEN 1
                               PERFORM DEPOSITAR
                           WHEN 2
                               PERFORM SACAR
                           WHEN 3
                               PERFORM TRANSFERIR
                       END-EVALUATE
                   END-IF
               END-IF
           END-IF.

       DEPOSITAR.
           ADD WS-VALOR TO WS-CONTA-SALDO(WS-INDICE-CONTA)
               ON SIZE ERROR
                   MOVE "Limite do saldo excedido" TO WS-MOTIVO
               NOT ON SIZE ERROR
                   MOVE "APROVADA" TO WS-STATUS
           END-ADD.

       SACAR.
           IF WS-VALOR > WS-CONTA-SALDO(WS-INDICE-CONTA)
               MOVE "Saldo insuficiente" TO WS-MOTIVO
           ELSE
               SUBTRACT WS-VALOR
                   FROM WS-CONTA-SALDO(WS-INDICE-CONTA)
                   ON SIZE ERROR
                       MOVE "Erro no calculo do saldo" TO WS-MOTIVO
                   NOT ON SIZE ERROR
                       MOVE "APROVADA" TO WS-STATUS
               END-SUBTRACT
           END-IF.

       TRANSFERIR.
           IF WS-VALOR > WS-CONTA-SALDO(WS-INDICE-CONTA)
               MOVE "Saldo insuficiente" TO WS-MOTIVO
           ELSE
               MOVE "S" TO WS-CALCULOS-OK

               COMPUTE WS-NOVO-SALDO-ORIGEM =
                   WS-CONTA-SALDO(WS-INDICE-CONTA) - WS-VALOR
                   ON SIZE ERROR
                       MOVE "N" TO WS-CALCULOS-OK
                       MOVE "Erro no calculo do saldo origem"
                           TO WS-MOTIVO
               END-COMPUTE

               IF WS-CALCULOS-OK = "S"
                   COMPUTE WS-NOVO-SALDO-DESTINO =
                       WS-CONTA-SALDO(WS-INDICE-DESTINO) + WS-VALOR
                       ON SIZE ERROR
                           MOVE "N" TO WS-CALCULOS-OK
                           MOVE "Limite do saldo destino excedido"
                               TO WS-MOTIVO
                   END-COMPUTE
               END-IF

               IF WS-CALCULOS-OK = "S"
                   MOVE WS-NOVO-SALDO-ORIGEM
                       TO WS-CONTA-SALDO(WS-INDICE-CONTA)
                   MOVE WS-NOVO-SALDO-DESTINO
                       TO WS-CONTA-SALDO(WS-INDICE-DESTINO)
                   MOVE "APROVADA" TO WS-STATUS
               END-IF
           END-IF.

       PERGUNTAR-CONTINUACAO.
           DISPLAY "Deseja processar outra transacao? (S/N): "
           ACCEPT WS-CONTINUAR
           MOVE FUNCTION UPPER-CASE(WS-CONTINUAR)
               TO WS-CONTINUAR

           PERFORM UNTIL WS-CONTINUAR = "S"
               OR WS-CONTINUAR = "N"
               DISPLAY "Opcao invalida. Digite S ou N: "
               ACCEPT WS-CONTINUAR
               MOVE FUNCTION UPPER-CASE(WS-CONTINUAR)
                   TO WS-CONTINUAR
           END-PERFORM.
 
 