       IDENTIFICATION DIVISION.
       PROGRAM-ID. CB7-BATCH.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT ARQUIVO-CLIENTES
               ASSIGN TO "CLIENTES.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-CLIENTES.
           SELECT ARQUIVO-CONTAS
               ASSIGN TO "CONTAS.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-CONTAS.
           SELECT ARQUIVO-TRANSACOES
               ASSIGN TO "TRANSACOES.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-TRANSACOES.
           SELECT SAIDA-CONTAS
               ASSIGN TO "CONTAS-ATUALIZADAS.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-SAIDA-CONTAS.
           SELECT SAIDA-TRANSACOES
               ASSIGN TO "TRANSACOES-PROCESSADAS.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-SAIDA-TRANSACOES.
           SELECT LEITURA-TRANSACOES-PROCESSADAS
               ASSIGN TO "TRANSACOES-PROCESSADAS.dat"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-LEITURA-PROCESSADAS.
           SELECT SAIDA-RELATORIO
               ASSIGN TO "RELATORIO.txt"
               ORGANIZATION IS LINE SEQUENTIAL
               FILE STATUS IS WS-STATUS-RELATORIO.

       DATA DIVISION.
       FILE SECTION.
       FD ARQUIVO-CLIENTES.
       01 REGISTRO-CLIENTE.
          05 FD-CLIENTE-CPF       PIC X(11).
          05 FD-CLIENTE-NOME      PIC X(40).
          05 FD-CLIENTE-TELEFONE  PIC X(11).
          05 FD-CLIENTE-EMAIL     PIC X(30).

       FD ARQUIVO-CONTAS.
       01 REGISTRO-CONTA.
          05 FD-CONTA-NUMERO  PIC X(10).
          05 FD-CONTA-AGENCIA PIC X(4).
          05 FD-CONTA-TIPO    PIC X(10).
          05 FD-CONTA-SALDO   PIC 9(11)V99.
          05 FD-CONTA-CPF     PIC X(11).

       FD ARQUIVO-TRANSACOES.
       01 REGISTRO-TRANSACAO.
          05 FD-TRANS-CONTA-ORIGEM  PIC X(10).
          05 FD-TRANS-TIPO          PIC 9.
          05 FD-TRANS-VALOR         PIC 9(11)V99.
          05 FD-TRANS-CONTA-DESTINO PIC X(10).

       FD SAIDA-CONTAS.
       01 REGISTRO-CONTA-SAIDA.
          05 OUT-CONTA-NUMERO  PIC X(10).
          05 OUT-CONTA-AGENCIA PIC X(4).
          05 OUT-CONTA-TIPO    PIC X(10).
          05 OUT-CONTA-SALDO   PIC 9(11)V99.
          05 OUT-CONTA-CPF     PIC X(11).

       FD SAIDA-TRANSACOES.
       01 REGISTRO-TRANSACAO-SAIDA.
          05 OUT-TRANS-ORIGEM    PIC X(10).
          05 OUT-SEP-1           PIC X.
          05 OUT-TRANS-TIPO      PIC 9.
          05 OUT-SEP-2           PIC X.
          05 OUT-TRANS-VALOR     PIC Z(10)9.99.
          05 OUT-SEP-3           PIC X.
          05 OUT-TRANS-DESTINO   PIC X(10).
          05 OUT-SEP-4           PIC X.
          05 OUT-TRANS-STATUS    PIC X(8).
          05 OUT-SEP-5           PIC X.
          05 OUT-TRANS-MOTIVO    PIC X(40).

         FD LEITURA-TRANSACOES-PROCESSADAS.
         01 REGISTRO-TRANSACAO-PROCESSADA.
             05 IN-TRANS-ORIGEM   PIC X(10).
             05 IN-SEP-1          PIC X.
             05 IN-TRANS-TIPO     PIC X.
             05 IN-SEP-2          PIC X.
             05 IN-TRANS-VALOR    PIC X(14).
             05 IN-SEP-3          PIC X.
             05 IN-TRANS-DESTINO  PIC X(10).
             05 IN-SEP-4          PIC X.
             05 IN-TRANS-STATUS   PIC X(8).
             05 IN-SEP-5          PIC X.
             05 IN-TRANS-MOTIVO   PIC X(40).

         FD SAIDA-RELATORIO.
        01 REGISTRO-RELATORIO PIC X(76).

       WORKING-STORAGE SECTION.
       01 WS-TABELA-CLIENTES.
          05 WS-CLIENTE OCCURS 100 TIMES.
             10 WS-CLIENTE-CPF      PIC X(11).
             10 WS-CLIENTE-NOME     PIC X(40).
             10 WS-CLIENTE-TELEFONE PIC X(11).
             10 WS-CLIENTE-EMAIL    PIC X(30).

       01 WS-TABELA-CONTAS.
          05 WS-CONTA OCCURS 100 TIMES.
             10 WS-CONTA-NUMERO  PIC X(10).
             10 WS-CONTA-AGENCIA PIC X(4).
             10 WS-CONTA-TIPO    PIC X(10).
             10 WS-CONTA-SALDO   PIC 9(11)V99.
             10 WS-CONTA-CPF     PIC X(11).

       01 WS-QTD-CLIENTES PIC 9(4) COMP-5 VALUE 0.
       01 WS-QTD-CONTAS   PIC 9(4) COMP-5 VALUE 0.
       01 WS-INDICE       PIC 9(4) COMP-5 VALUE 0.
       01 WS-INDICE-ORIGEM PIC 9(4) COMP-5 VALUE 0.
       01 WS-INDICE-DESTINO PIC 9(4) COMP-5 VALUE 0.

       01 WS-FIM-CLIENTES    PIC X VALUE "N".
       01 WS-FIM-CONTAS      PIC X VALUE "N".
       01 WS-FIM-TRANSACOES  PIC X VALUE "N".
       01 WS-ERRO-FATAL      PIC X VALUE "N".
       01 WS-STATUS-CLIENTES PIC XX.
       01 WS-STATUS-CONTAS   PIC XX.
       01 WS-STATUS-TRANSACOES PIC XX.
       01 WS-STATUS-SAIDA-CONTAS PIC XX.
       01 WS-STATUS-SAIDA-TRANSACOES PIC XX.
         01 WS-STATUS-LEITURA-PROCESSADAS PIC XX.
         01 WS-STATUS-RELATORIO PIC XX.

       01 WS-STATUS-TRANSACAO PIC X(8).
       01 WS-MOTIVO           PIC X(40).
       01 WS-NOVO-SALDO-ORIGEM PIC 9(11)V99.
       01 WS-NOVO-SALDO-DESTINO PIC 9(11)V99.
       01 WS-CALCULOS-OK      PIC X.

       01 WS-TOTAL-TRANSACOES PIC 9(9) COMP-5 VALUE 0.
       01 WS-TOTAL-APROVADAS  PIC 9(9) COMP-5 VALUE 0.
       01 WS-TOTAL-NEGADAS    PIC 9(9) COMP-5 VALUE 0.
       01 WS-TOTAL-EXIBICAO   PIC Z(8)9.
       01 WS-APROVADAS-EXIBICAO PIC Z(8)9.
       01 WS-NEGADAS-EXIBICAO PIC Z(8)9.
       01 WS-VALOR-EXIBICAO   PIC Z(10)9.99.

         01 WS-TOTAL-VALOR-DEPOSITOS PIC 9(15)V99 COMP-3 VALUE 0.
         01 WS-TOTAL-VALOR-SAQUES PIC 9(15)V99 COMP-3 VALUE 0.
         01 WS-TOTAL-VALOR-TRANSFERENCIAS PIC 9(15)V99 COMP-3 VALUE 0.
         01 WS-DEP-SALDO-EXIBICAO PIC Z(15)9.99.
         01 WS-SAQUE-SALDO-EXIBICAO PIC Z(15)9.99.
         01 WS-TRANSF-SALDO-EXIBICAO PIC Z(15)9.99.
         01 WS-SALDO-RELATORIO PIC Z(15)9.99.
         01 WS-LINHA-RELATORIO PIC X(76).
         01 WS-DATA-HORA PIC X(21).
         01 WS-DATA-RELATORIO PIC X(10).
         01 WS-FIM-LEITURA-PROCESSADAS PIC X VALUE "N".
         01 WS-REL-SEQUENCIA PIC 9(9) COMP-5 VALUE 0.
         01 WS-REL-SEQUENCIA-EDIT PIC Z(8)9.
         01 WS-REL-TIPO PIC X(15).

       PROCEDURE DIVISION.
       INICIO.
           PERFORM CARREGAR-CLIENTES
           IF WS-ERRO-FATAL = "N"
               PERFORM CARREGAR-CONTAS
           END-IF
           IF WS-ERRO-FATAL = "N"
               PERFORM PROCESSAR-TRANSACOES
           END-IF
           IF WS-ERRO-FATAL = "N"
               PERFORM GRAVAR-CONTAS-ATUALIZADAS
           END-IF
           IF WS-ERRO-FATAL = "N"
               PERFORM GERAR-RELATORIO
           END-IF

           PERFORM EXIBIR-RESUMO
           IF WS-ERRO-FATAL = "S"
               DISPLAY "Processamento interrompido por erro."
           END-IF
           STOP RUN.

       CARREGAR-CLIENTES.
           OPEN INPUT ARQUIVO-CLIENTES
           IF WS-STATUS-CLIENTES NOT = "00"
               DISPLAY "Erro ao abrir CLIENTES.dat. Status: "
                   WS-STATUS-CLIENTES
               MOVE "S" TO WS-ERRO-FATAL
           ELSE
               MOVE "N" TO WS-FIM-CLIENTES
               PERFORM UNTIL WS-FIM-CLIENTES = "S"
                   OR WS-ERRO-FATAL = "S"
                   READ ARQUIVO-CLIENTES
                       AT END
                           MOVE "S" TO WS-FIM-CLIENTES
                       NOT AT END
                           IF WS-QTD-CLIENTES >= 100
                               DISPLAY "Limite de clientes excedido."
                               MOVE "S" TO WS-ERRO-FATAL
                               MOVE "S" TO WS-FIM-CLIENTES
                           ELSE
                               ADD 1 TO WS-QTD-CLIENTES
                               MOVE FD-CLIENTE-CPF
                                   TO WS-CLIENTE-CPF(
                                       WS-QTD-CLIENTES)
                               MOVE FD-CLIENTE-NOME
                                   TO WS-CLIENTE-NOME(
                                       WS-QTD-CLIENTES)
                               MOVE FD-CLIENTE-TELEFONE
                                   TO WS-CLIENTE-TELEFONE(
                                       WS-QTD-CLIENTES)
                               MOVE FD-CLIENTE-EMAIL
                                   TO WS-CLIENTE-EMAIL(
                                       WS-QTD-CLIENTES)
                           END-IF
                   END-READ

                   IF WS-STATUS-CLIENTES = "06"
                       MOVE "S" TO WS-FIM-CLIENTES
                   ELSE
                       IF WS-FIM-CLIENTES NOT = "S"
                           AND WS-STATUS-CLIENTES NOT = "00"
                           AND WS-STATUS-CLIENTES NOT = "10"
                           DISPLAY "Erro ao ler CLIENTES.dat. "
                               "Status: " WS-STATUS-CLIENTES
                           MOVE "S" TO WS-ERRO-FATAL
                           MOVE "S" TO WS-FIM-CLIENTES
                       END-IF
                   END-IF
               END-PERFORM
               CLOSE ARQUIVO-CLIENTES
               IF WS-STATUS-CLIENTES NOT = "00"
                   DISPLAY "Erro ao fechar CLIENTES.dat. Status: "
                       WS-STATUS-CLIENTES
                   MOVE "S" TO WS-ERRO-FATAL
               END-IF
           END-IF.

       CARREGAR-CONTAS.
           OPEN INPUT ARQUIVO-CONTAS
           IF WS-STATUS-CONTAS NOT = "00"
               DISPLAY "Erro ao abrir CONTAS.dat. Status: "
                   WS-STATUS-CONTAS
               MOVE "S" TO WS-ERRO-FATAL
           ELSE
               MOVE "N" TO WS-FIM-CONTAS
               PERFORM UNTIL WS-FIM-CONTAS = "S"
                   OR WS-ERRO-FATAL = "S"
                   READ ARQUIVO-CONTAS
                       AT END
                           MOVE "S" TO WS-FIM-CONTAS
                       NOT AT END
                           IF WS-QTD-CONTAS >= 100
                               DISPLAY "Limite de contas excedido."
                               MOVE "S" TO WS-ERRO-FATAL
                               MOVE "S" TO WS-FIM-CONTAS
                           ELSE
                               ADD 1 TO WS-QTD-CONTAS
                               MOVE FD-CONTA-NUMERO
                                   TO WS-CONTA-NUMERO(
                                       WS-QTD-CONTAS)
                               MOVE FD-CONTA-AGENCIA
                                   TO WS-CONTA-AGENCIA(
                                       WS-QTD-CONTAS)
                               MOVE FD-CONTA-TIPO
                                   TO WS-CONTA-TIPO(
                                       WS-QTD-CONTAS)
                               MOVE FD-CONTA-SALDO
                                   TO WS-CONTA-SALDO(
                                       WS-QTD-CONTAS)
                               MOVE FD-CONTA-CPF
                                   TO WS-CONTA-CPF(
                                       WS-QTD-CONTAS)
                           END-IF
                   END-READ

                   IF WS-STATUS-CONTAS = "06"
                       MOVE "S" TO WS-FIM-CONTAS
                   ELSE
                       IF WS-FIM-CONTAS NOT = "S"
                           AND WS-STATUS-CONTAS NOT = "00"
                           AND WS-STATUS-CONTAS NOT = "10"
                           DISPLAY "Erro ao ler CONTAS.dat. "
                               "Status: " WS-STATUS-CONTAS
                           MOVE "S" TO WS-ERRO-FATAL
                           MOVE "S" TO WS-FIM-CONTAS
                       END-IF
                   END-IF
               END-PERFORM
               CLOSE ARQUIVO-CONTAS
               IF WS-STATUS-CONTAS NOT = "00"
                   DISPLAY "Erro ao fechar CONTAS.dat. Status: "
                       WS-STATUS-CONTAS
                   MOVE "S" TO WS-ERRO-FATAL
               END-IF
           END-IF.

       PROCESSAR-TRANSACOES.
           OPEN INPUT ARQUIVO-TRANSACOES
           IF WS-STATUS-TRANSACOES NOT = "00"
               DISPLAY "Erro ao abrir TRANSACOES.dat. Status: "
                   WS-STATUS-TRANSACOES
               MOVE "S" TO WS-ERRO-FATAL
           ELSE
               OPEN OUTPUT SAIDA-TRANSACOES
               IF WS-STATUS-SAIDA-TRANSACOES NOT = "00"
                   DISPLAY "Erro ao criar "
                       "TRANSACOES-PROCESSADAS.dat. Status: "
                       WS-STATUS-SAIDA-TRANSACOES
                   MOVE "S" TO WS-ERRO-FATAL
               ELSE
                   MOVE "N" TO WS-FIM-TRANSACOES
                   PERFORM UNTIL WS-FIM-TRANSACOES = "S"
                       OR WS-ERRO-FATAL = "S"
                       READ ARQUIVO-TRANSACOES
                           AT END
                               MOVE "S" TO WS-FIM-TRANSACOES
                           NOT AT END
                               ADD 1 TO WS-TOTAL-TRANSACOES
                               PERFORM PROCESSAR-REGISTRO
                               PERFORM GRAVAR-TRANSACAO-PROCESSADA
                       END-READ

                       IF WS-STATUS-TRANSACOES = "06"
                           MOVE "S" TO WS-FIM-TRANSACOES
                       ELSE
                           IF WS-FIM-TRANSACOES NOT = "S"
                               AND WS-STATUS-TRANSACOES NOT = "00"
                               AND WS-STATUS-TRANSACOES NOT = "10"
                               DISPLAY "Erro ao ler "
                                   "TRANSACOES.dat. Status: "
                                   WS-STATUS-TRANSACOES
                               MOVE "S" TO WS-ERRO-FATAL
                               MOVE "S" TO WS-FIM-TRANSACOES
                           END-IF
                       END-IF
                   END-PERFORM

                   CLOSE SAIDA-TRANSACOES
                   IF WS-STATUS-SAIDA-TRANSACOES NOT = "00"
                       DISPLAY "Erro ao fechar "
                           "TRANSACOES-PROCESSADAS.dat. Status: "
                           WS-STATUS-SAIDA-TRANSACOES
                       MOVE "S" TO WS-ERRO-FATAL
                   END-IF
               END-IF

               CLOSE ARQUIVO-TRANSACOES
               IF WS-STATUS-TRANSACOES NOT = "00"
                   DISPLAY "Erro ao fechar TRANSACOES.dat. Status: "
                       WS-STATUS-TRANSACOES
                   MOVE "S" TO WS-ERRO-FATAL
               END-IF
           END-IF.

       PROCESSAR-REGISTRO.
           MOVE "NEGADA" TO WS-STATUS-TRANSACAO
           MOVE SPACES TO WS-MOTIVO
           MOVE 0 TO WS-INDICE-ORIGEM
           MOVE 0 TO WS-INDICE-DESTINO

           PERFORM VARYING WS-INDICE FROM 1 BY 1
               UNTIL WS-INDICE > WS-QTD-CONTAS
                   OR WS-INDICE-ORIGEM > 0
               IF WS-CONTA-NUMERO(WS-INDICE)
                   = FD-TRANS-CONTA-ORIGEM
                   MOVE WS-INDICE TO WS-INDICE-ORIGEM
               END-IF
           END-PERFORM

           IF WS-INDICE-ORIGEM = 0
               MOVE "Conta origem nao encontrada" TO WS-MOTIVO
           ELSE
               IF FD-TRANS-VALOR <= 0
                   MOVE "Valor deve ser maior que zero"
                       TO WS-MOTIVO
               ELSE
                   EVALUATE FD-TRANS-TIPO
                       WHEN 1
                           PERFORM PROCESSAR-DEPOSITO
                       WHEN 2
                           PERFORM PROCESSAR-SAQUE
                       WHEN 3
                           PERFORM PROCESSAR-TRANSFERENCIA
                       WHEN OTHER
                           MOVE "Tipo de transacao invalido"
                               TO WS-MOTIVO
                   END-EVALUATE
               END-IF
           END-IF

           IF WS-STATUS-TRANSACAO = "APROVADA"
               ADD 1 TO WS-TOTAL-APROVADAS
               PERFORM ACUMULAR-TOTAIS-VALOR
           ELSE
               ADD 1 TO WS-TOTAL-NEGADAS
           END-IF.

       ACUMULAR-TOTAIS-VALOR.
           EVALUATE FD-TRANS-TIPO
               WHEN 1
                   ADD FD-TRANS-VALOR TO WS-TOTAL-VALOR-DEPOSITOS
                       ON SIZE ERROR
                           DISPLAY "Total de depositos excedido."
                           MOVE "S" TO WS-ERRO-FATAL
                   END-ADD
               WHEN 2
                   ADD FD-TRANS-VALOR TO WS-TOTAL-VALOR-SAQUES
                       ON SIZE ERROR
                           DISPLAY "Total de saques excedido."
                           MOVE "S" TO WS-ERRO-FATAL
                   END-ADD
               WHEN 3
                   ADD FD-TRANS-VALOR
                       TO WS-TOTAL-VALOR-TRANSFERENCIAS
                       ON SIZE ERROR
                           DISPLAY "Total de transferencias excedido."
                           MOVE "S" TO WS-ERRO-FATAL
                   END-ADD
           END-EVALUATE.

       PROCESSAR-DEPOSITO.
           ADD FD-TRANS-VALOR
               TO WS-CONTA-SALDO(WS-INDICE-ORIGEM)
               ON SIZE ERROR
                   MOVE "Limite do saldo excedido" TO WS-MOTIVO
               NOT ON SIZE ERROR
                   MOVE "APROVADA" TO WS-STATUS-TRANSACAO
           END-ADD.

       PROCESSAR-SAQUE.
           IF FD-TRANS-VALOR
               > WS-CONTA-SALDO(WS-INDICE-ORIGEM)
               MOVE "Saldo insuficiente" TO WS-MOTIVO
           ELSE
               SUBTRACT FD-TRANS-VALOR
                   FROM WS-CONTA-SALDO(WS-INDICE-ORIGEM)
                   ON SIZE ERROR
                       MOVE "Erro no calculo do saldo" TO WS-MOTIVO
                   NOT ON SIZE ERROR
                       MOVE "APROVADA" TO WS-STATUS-TRANSACAO
               END-SUBTRACT
           END-IF.

       PROCESSAR-TRANSFERENCIA.
           PERFORM VARYING WS-INDICE FROM 1 BY 1
               UNTIL WS-INDICE > WS-QTD-CONTAS
                   OR WS-INDICE-DESTINO > 0
               IF WS-CONTA-NUMERO(WS-INDICE)
                   = FD-TRANS-CONTA-DESTINO
                   MOVE WS-INDICE TO WS-INDICE-DESTINO
               END-IF
           END-PERFORM

           IF WS-INDICE-DESTINO = 0
               MOVE "Conta destino nao encontrada" TO WS-MOTIVO
           ELSE
               IF WS-INDICE-DESTINO = WS-INDICE-ORIGEM
                   MOVE "Conta destino igual a origem" TO WS-MOTIVO
               ELSE
                   IF FD-TRANS-VALOR
                       > WS-CONTA-SALDO(WS-INDICE-ORIGEM)
                       MOVE "Saldo insuficiente" TO WS-MOTIVO
                   ELSE
                       PERFORM CALCULAR-TRANSFERENCIA
                   END-IF
               END-IF
           END-IF.

       CALCULAR-TRANSFERENCIA.
           MOVE "S" TO WS-CALCULOS-OK
           COMPUTE WS-NOVO-SALDO-ORIGEM =
               WS-CONTA-SALDO(WS-INDICE-ORIGEM)
               - FD-TRANS-VALOR
               ON SIZE ERROR
                   MOVE "N" TO WS-CALCULOS-OK
                   MOVE "Erro no calculo do saldo origem"
                       TO WS-MOTIVO
           END-COMPUTE

           IF WS-CALCULOS-OK = "S"
               COMPUTE WS-NOVO-SALDO-DESTINO =
                   WS-CONTA-SALDO(WS-INDICE-DESTINO)
                   + FD-TRANS-VALOR
                   ON SIZE ERROR
                       MOVE "N" TO WS-CALCULOS-OK
                       MOVE "Limite do saldo destino excedido"
                           TO WS-MOTIVO
               END-COMPUTE
           END-IF

           IF WS-CALCULOS-OK = "S"
               MOVE WS-NOVO-SALDO-ORIGEM
                   TO WS-CONTA-SALDO(WS-INDICE-ORIGEM)
               MOVE WS-NOVO-SALDO-DESTINO
                   TO WS-CONTA-SALDO(WS-INDICE-DESTINO)
               MOVE "APROVADA" TO WS-STATUS-TRANSACAO
           END-IF.

       GRAVAR-TRANSACAO-PROCESSADA.
           MOVE FD-TRANS-CONTA-ORIGEM TO OUT-TRANS-ORIGEM
           MOVE "|" TO OUT-SEP-1
           MOVE FD-TRANS-TIPO TO OUT-TRANS-TIPO
           MOVE "|" TO OUT-SEP-2
           MOVE FD-TRANS-VALOR TO WS-VALOR-EXIBICAO
           MOVE WS-VALOR-EXIBICAO TO OUT-TRANS-VALOR
           MOVE "|" TO OUT-SEP-3
           MOVE FD-TRANS-CONTA-DESTINO TO OUT-TRANS-DESTINO
           MOVE "|" TO OUT-SEP-4
           MOVE WS-STATUS-TRANSACAO TO OUT-TRANS-STATUS
           MOVE "|" TO OUT-SEP-5
           MOVE WS-MOTIVO TO OUT-TRANS-MOTIVO

           WRITE REGISTRO-TRANSACAO-SAIDA
           IF WS-STATUS-SAIDA-TRANSACOES NOT = "00"
               DISPLAY "Erro ao gravar "
                   "TRANSACOES-PROCESSADAS.dat. Status: "
                   WS-STATUS-SAIDA-TRANSACOES
               MOVE "S" TO WS-ERRO-FATAL
           END-IF.

       GRAVAR-CONTAS-ATUALIZADAS.
           OPEN OUTPUT SAIDA-CONTAS
           IF WS-STATUS-SAIDA-CONTAS NOT = "00"
               DISPLAY "Erro ao criar CONTAS-ATUALIZADAS.dat. "
                   "Status: " WS-STATUS-SAIDA-CONTAS
               MOVE "S" TO WS-ERRO-FATAL
           ELSE
               PERFORM VARYING WS-INDICE FROM 1 BY 1
                   UNTIL WS-INDICE > WS-QTD-CONTAS
                       OR WS-ERRO-FATAL = "S"
                   MOVE WS-CONTA-NUMERO(WS-INDICE)
                       TO OUT-CONTA-NUMERO
                   MOVE WS-CONTA-AGENCIA(WS-INDICE)
                       TO OUT-CONTA-AGENCIA
                   MOVE WS-CONTA-TIPO(WS-INDICE)
                       TO OUT-CONTA-TIPO
                   MOVE WS-CONTA-SALDO(WS-INDICE)
                       TO OUT-CONTA-SALDO
                   MOVE WS-CONTA-CPF(WS-INDICE)
                       TO OUT-CONTA-CPF
                   WRITE REGISTRO-CONTA-SAIDA
                   IF WS-STATUS-SAIDA-CONTAS NOT = "00"
                       DISPLAY "Erro ao gravar "
                           "CONTAS-ATUALIZADAS.dat. Status: "
                           WS-STATUS-SAIDA-CONTAS
                       MOVE "S" TO WS-ERRO-FATAL
                   END-IF
               END-PERFORM

               CLOSE SAIDA-CONTAS
               IF WS-STATUS-SAIDA-CONTAS NOT = "00"
                   DISPLAY "Erro ao fechar "
                       "CONTAS-ATUALIZADAS.dat. Status: "
                       WS-STATUS-SAIDA-CONTAS
                   MOVE "S" TO WS-ERRO-FATAL
               END-IF
           END-IF.

       EXIBIR-RESUMO.
           MOVE WS-TOTAL-TRANSACOES TO WS-TOTAL-EXIBICAO
           MOVE WS-TOTAL-APROVADAS TO WS-APROVADAS-EXIBICAO
           MOVE WS-TOTAL-NEGADAS TO WS-NEGADAS-EXIBICAO
           DISPLAY "RESUMO DO PROCESSAMENTO"
           DISPLAY "Transacoes lidas: " WS-TOTAL-EXIBICAO
           DISPLAY "Aprovadas:        " WS-APROVADAS-EXIBICAO
           DISPLAY "Negadas:          " WS-NEGADAS-EXIBICAO.

       GERAR-RELATORIO.
           OPEN INPUT LEITURA-TRANSACOES-PROCESSADAS
           IF WS-STATUS-LEITURA-PROCESSADAS NOT = "00"
               DISPLAY "Erro ao abrir "
                   "TRANSACOES-PROCESSADAS.dat para relatorio. "
                   "Status: " WS-STATUS-LEITURA-PROCESSADAS
               MOVE "S" TO WS-ERRO-FATAL
           ELSE
               OPEN OUTPUT SAIDA-RELATORIO
               IF WS-STATUS-RELATORIO NOT = "00"
                   DISPLAY "Erro ao criar RELATORIO.txt. Status: "
                       WS-STATUS-RELATORIO
                   MOVE "S" TO WS-ERRO-FATAL
               ELSE
                   PERFORM ESCREVER-CABECALHO-RELATORIO
                   MOVE "N" TO WS-FIM-LEITURA-PROCESSADAS
                   PERFORM UNTIL WS-FIM-LEITURA-PROCESSADAS = "S"
                       OR WS-ERRO-FATAL = "S"
                       READ LEITURA-TRANSACOES-PROCESSADAS
                           AT END
                               MOVE "S" TO
                                   WS-FIM-LEITURA-PROCESSADAS
                           NOT AT END
                               ADD 1 TO WS-REL-SEQUENCIA
                               PERFORM
                                   ESCREVER-TRANSACAO-RELATORIO
                       END-READ

                       IF WS-STATUS-LEITURA-PROCESSADAS = "06"
                           MOVE "S" TO WS-FIM-LEITURA-PROCESSADAS
                       ELSE
                           IF WS-FIM-LEITURA-PROCESSADAS NOT = "S"
                               AND WS-STATUS-LEITURA-PROCESSADAS
                                   NOT = "00"
                               AND WS-STATUS-LEITURA-PROCESSADAS
                                   NOT = "10"
                               DISPLAY "Erro ao ler "
                                   "TRANSACOES-PROCESSADAS.dat. "
                                   "Status: "
                                   WS-STATUS-LEITURA-PROCESSADAS
                               MOVE "S" TO WS-ERRO-FATAL
                               MOVE "S" TO
                                   WS-FIM-LEITURA-PROCESSADAS
                           END-IF
                       END-IF
                   END-PERFORM

                   IF WS-ERRO-FATAL = "N"
                       MOVE ALL "-" TO WS-LINHA-RELATORIO
                       PERFORM GRAVAR-LINHA-RELATORIO
                       PERFORM ESCREVER-RESUMO-RELATORIO
                       PERFORM ESCREVER-SALDOS-RELATORIO
                       PERFORM ESCREVER-RODAPE-RELATORIO
                   END-IF

                   CLOSE SAIDA-RELATORIO
                   IF WS-STATUS-RELATORIO NOT = "00"
                       DISPLAY "Erro ao fechar RELATORIO.txt. "
                           "Status: " WS-STATUS-RELATORIO
                       MOVE "S" TO WS-ERRO-FATAL
                   END-IF
               END-IF

               CLOSE LEITURA-TRANSACOES-PROCESSADAS
               IF WS-STATUS-LEITURA-PROCESSADAS NOT = "00"
                   DISPLAY "Erro ao fechar "
                       "TRANSACOES-PROCESSADAS.dat. Status: "
                       WS-STATUS-LEITURA-PROCESSADAS
                   MOVE "S" TO WS-ERRO-FATAL
               END-IF
           END-IF.

       ESCREVER-CABECALHO-RELATORIO.
           MOVE FUNCTION CURRENT-DATE TO WS-DATA-HORA
           MOVE WS-DATA-HORA(7:2) TO WS-DATA-RELATORIO(1:2)
           MOVE "/" TO WS-DATA-RELATORIO(3:1)
           MOVE WS-DATA-HORA(5:2) TO WS-DATA-RELATORIO(4:2)
           MOVE "/" TO WS-DATA-RELATORIO(6:1)
           MOVE WS-DATA-HORA(1:4) TO WS-DATA-RELATORIO(7:4)

           MOVE ALL "=" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE "           RELATORIO DE PROCESSAMENTO BANCARIO"
               TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE "           Data: " TO WS-LINHA-RELATORIO(1:17)
           MOVE WS-DATA-RELATORIO TO WS-LINHA-RELATORIO(18:10)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "=" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE "TRANSACOES PROCESSADAS" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE "#" TO WS-LINHA-RELATORIO(9:1)
           MOVE "ORIGEM" TO WS-LINHA-RELATORIO(11:6)
           MOVE "TIPO" TO WS-LINHA-RELATORIO(23:4)
           MOVE "VALOR" TO WS-LINHA-RELATORIO(39:5)
           MOVE "DESTINO" TO WS-LINHA-RELATORIO(55:7)
           MOVE "STATUS" TO WS-LINHA-RELATORIO(66:6)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO.

       ESCREVER-TRANSACAO-RELATORIO.
           MOVE WS-REL-SEQUENCIA TO WS-REL-SEQUENCIA-EDIT
           EVALUATE IN-TRANS-TIPO
               WHEN "1"
                   MOVE "DEPOSITO" TO WS-REL-TIPO
               WHEN "2"
                   MOVE "SAQUE" TO WS-REL-TIPO
               WHEN "3"
                   MOVE "TRANSFERENCIA" TO WS-REL-TIPO
               WHEN OTHER
                   MOVE "TIPO INVALIDO" TO WS-REL-TIPO
           END-EVALUATE

           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE WS-REL-SEQUENCIA-EDIT
               TO WS-LINHA-RELATORIO(1:9)
           MOVE IN-TRANS-ORIGEM TO WS-LINHA-RELATORIO(11:10)
           MOVE WS-REL-TIPO TO WS-LINHA-RELATORIO(23:15)
           MOVE IN-TRANS-VALOR TO WS-LINHA-RELATORIO(39:14)
           MOVE IN-TRANS-DESTINO TO WS-LINHA-RELATORIO(55:10)
           MOVE IN-TRANS-STATUS TO WS-LINHA-RELATORIO(66:8)
           PERFORM GRAVAR-LINHA-RELATORIO.

       ESCREVER-RESUMO-RELATORIO.
           MOVE WS-TOTAL-TRANSACOES TO WS-TOTAL-EXIBICAO
           MOVE WS-TOTAL-APROVADAS TO WS-APROVADAS-EXIBICAO
           MOVE WS-TOTAL-NEGADAS TO WS-NEGADAS-EXIBICAO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE "RESUMO DE TRANSACOES" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO

           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE " Total de transacoes lidas:"
               TO WS-LINHA-RELATORIO(1:28)
           MOVE WS-TOTAL-EXIBICAO TO WS-LINHA-RELATORIO(35:9)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE " Aprovadas:" TO WS-LINHA-RELATORIO(1:11)
           MOVE WS-APROVADAS-EXIBICAO
               TO WS-LINHA-RELATORIO(35:9)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE " Negadas:" TO WS-LINHA-RELATORIO(1:9)
           MOVE WS-NEGADAS-EXIBICAO
               TO WS-LINHA-RELATORIO(35:9)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO

           MOVE WS-TOTAL-VALOR-DEPOSITOS TO WS-DEP-SALDO-EXIBICAO
           MOVE WS-TOTAL-VALOR-SAQUES TO WS-SAQUE-SALDO-EXIBICAO
           MOVE WS-TOTAL-VALOR-TRANSFERENCIAS
               TO WS-TRANSF-SALDO-EXIBICAO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE " Valor total de depositos:" 
               TO WS-LINHA-RELATORIO(1:27)
           MOVE WS-DEP-SALDO-EXIBICAO
               TO WS-LINHA-RELATORIO(35:19)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE " Valor total de saques:" 
               TO WS-LINHA-RELATORIO(1:24)
           MOVE WS-SAQUE-SALDO-EXIBICAO
               TO WS-LINHA-RELATORIO(35:19)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE " Valor total de transferencias:" 
               TO WS-LINHA-RELATORIO(1:32)
           MOVE WS-TRANSF-SALDO-EXIBICAO
               TO WS-LINHA-RELATORIO(35:19)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO.

       ESCREVER-SALDOS-RELATORIO.
           MOVE SPACES TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE "SALDO FINAL DAS CONTAS" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE SPACES TO WS-LINHA-RELATORIO
           MOVE "CONTA" TO WS-LINHA-RELATORIO(2:5)
           MOVE "AGENCIA" TO WS-LINHA-RELATORIO(14:7)
           MOVE "TIPO" TO WS-LINHA-RELATORIO(23:4)
           MOVE "SALDO" TO WS-LINHA-RELATORIO(36:5)
           MOVE "CPF" TO WS-LINHA-RELATORIO(58:3)
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO

           PERFORM VARYING WS-INDICE FROM 1 BY 1
               UNTIL WS-INDICE > WS-QTD-CONTAS
                   OR WS-ERRO-FATAL = "S"
               MOVE WS-CONTA-SALDO(WS-INDICE)
                   TO WS-SALDO-RELATORIO
               MOVE SPACES TO WS-LINHA-RELATORIO
               MOVE WS-CONTA-NUMERO(WS-INDICE)
                   TO WS-LINHA-RELATORIO(2:10)
               MOVE WS-CONTA-AGENCIA(WS-INDICE)
                   TO WS-LINHA-RELATORIO(14:4)
               MOVE WS-CONTA-TIPO(WS-INDICE)
                   TO WS-LINHA-RELATORIO(23:10)
               MOVE WS-SALDO-RELATORIO
                   TO WS-LINHA-RELATORIO(36:19)
               MOVE WS-CONTA-CPF(WS-INDICE)
                   TO WS-LINHA-RELATORIO(58:11)
               PERFORM GRAVAR-LINHA-RELATORIO
           END-PERFORM
           MOVE ALL "-" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO.

       ESCREVER-RODAPE-RELATORIO.
           MOVE SPACES TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "=" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE "           FIM DO RELATORIO"
               TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO
           MOVE ALL "=" TO WS-LINHA-RELATORIO
           PERFORM GRAVAR-LINHA-RELATORIO.

       GRAVAR-LINHA-RELATORIO.
           WRITE REGISTRO-RELATORIO FROM WS-LINHA-RELATORIO
           IF WS-STATUS-RELATORIO NOT = "00"
               DISPLAY "Erro ao gravar RELATORIO.txt. Status: "
                   WS-STATUS-RELATORIO
               MOVE "S" TO WS-ERRO-FATAL
           END-IF.
