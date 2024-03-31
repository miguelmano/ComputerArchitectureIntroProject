;Realizado Por Miguel Mano Nº99286
;e Stanislaw Talejko Nº99330
;-------------------------Constantes---------------------------------------------
;interrupcoes
INT_MASK        EQU     FFFAh
INT_MASK_VAL    EQU     80FFh ; 1000 0000 1111 1111 B
; timer
TIMER_CONTROL   EQU     FFF7h
TIMER_COUNTER   EQU     FFF6h
;terminal
TERM_WRITE      EQU     FFFEh
TERM_STATUS     EQU     FFFDh
TERM_CURSOR     EQU     FFFCh
;DISPLAY DE 7 SEGMENTOS
DISP7SEG_0      EQU     FFF0h
DISP7SEG_1      EQU     FFF1h
DISP7SEG_2      EQU     FFF2h
DISP7SEG_3      EQU     FFF3h
DISP7SEG_4      EQU     FFEEh
DISP7SEG_5      EQU     FFEFh
;constantes do JOGO
MDELINHA        EQU     100H
COLUNAS         EQU     30H
STACKBS         EQU     3000H
HMAX            EQU     4
POSVET          EQU     4000H
;--------------------------------STRINGS-----------------------------------------
DINO            STR     'R'
CACTO           STR     'Y'
CHAO            STR     'W\',0
GAMEOVER        STR     'GAME OVER',0
;---------------------VARIAVEIS-------------------------------------------------
                ORIG    4000H
VETOR           TAB     30H
                
                ORIG    2000H      
CRUSOR          WORD    0600H
X               WORD    7
POSDINO         WORD    1
FASESALTO       WORD    0
GAMEONOFF       WORD    0
PONTOS          WORD    0
UNIDADES        WORD    0
DEZENAS         WORD    0
CENTENAS        WORD    0
MILHARES        WORD    0
;----------------------MAIN-----------------------------------------------------
                ORIG    0000H
                MVI     R1,INT_MASK
                MVI     R2,INT_MASK_VAL ;PASSA PARA A MASCARA AS INTERRUPCOES
                STOR    M[R1],R2      ;ATIVAS

                ENI      ;LIGA AS INTERRUPCOES
                
                MVI     R6,STACKBS
;==============================================================================
;FUNCAO PRINCIPAL ENCARREGUE DO FUNCIONAMENTO DO JOGO
;SE GAMEONOFF=1 O JOGO CORRE CASO CONTRARIO FICA A ESPERA
;DA ALTERACAO DO VALOR CAUSADA PELA INTERRUPCAO DO BOTAO 0
;==============================================================================
JOGO:           MVI     R1,GAMEONOFF
                LOAD    R2,M[R1]
                CMP     R2,R0
                BR.Z    JOGO
                JAL     INI_TIMER
                JAL     ATUALIZAJOGO 
                MVI     R1,FASESALTO
                LOAD    R2,M[R1]
                CMP     R2,R0
                JAL.NZ  SALTO
                MVI     R2,TERM_CURSOR
                MVI     R5,FFFFH
                STOR    M[R2],R5
                JAL     PRINTCHAO
                JAL     PRINTDINO
                MVI     R2,TERM_CURSOR
                MVI     R5,0600H
                STOR    M[R2],R5
                MVI     R2,VETOR
                
                JAL     STRINGA
                JAL     COLISAO
                MVI     R1,GAMEONOFF
                MVI     R2,0
                STOR    M[R1],R2
                JAL     PONTUACAO
                BR      JOGO
;-------------------PRINT CHAO----------------------
;==============================================================================
;FUNCAO RESPONSAVEL PELA ATUALIZACAO DO CHAO
;==============================================================================
PRINTCHAO:      MVI     R5,COLUNAS
                MVI     R3,0700H
.recycle:       MVI     R2,CHAO
.cycle:         LOAD    R4,M[R2]
                CMP     R4,R0
                BR.Z    .recycle
                MVI     R1,TERM_CURSOR
                STOR    M[R1],R3
                MVI     R1,TERM_WRITE
                STOR    M[R1],R4
                INC     R3
                INC     R2
                DEC     R5
                CMP     R5,R0
                BR.P    .cycle
                
.fimchao:       MVI     R2,CHAO
                LOAD    R4,M[R2]
                INC     R2
                LOAD    R5,M[R2]
                STOR    M[R2],R4
                DEC     R2
                STOR    M[R2],R5
                JMP     R7
                
;-------------------STRINGA----------------------
;==============================================================================
;FUNCAO ENCARREGUE POR TRANSFORMAR A ALTURA DOS CATOS EM STRING
;RECEBE A ALTURA DOS CATOS DO VETOR
;==============================================================================
STRINGA:        MVI     R4,COLUNAS
.stringa:       STOR    M[R6],R4
                INC     R6
                STOR    M[R6],R5
                INC     R6
                LOAD    R5,M[R2]
                CMP     R5,R0
                BR.Z    .incursor
                MVI     R4,CACTO
                LOAD    R3,M[R4]
                MVI     R4,1
                CMP     R5,R4
                BR.P    .escrevecoluna
                MVI     R1,TERM_WRITE
                STOR    M[R1],R3

.incursor:      DEC     R6 
                LOAD    R5,M[R6]        ;R5 - POSICAO CURSOR
                INC     R5
                MVI     R1,TERM_CURSOR
                STOR    M[R1],R5

                INC     R2              ;R2 - POSICAO DO VETOR

                DEC     R6             
                LOAD    R4,M[R6]
                DEC     R4              ;R4 - COUNTER
                CMP     R4,R0
                BR.P    .stringa
                JMP     R7

.escrevecoluna: DEC     R6
                LOAD    R4,M[R6]
                STOR    M[R6],R4
                INC     R6


.strloop:       MVI     R1,TERM_WRITE
                STOR    M[R1],R3
                MVI     R1,MDELINHA
                SUB     R4,R4,R1
                MVI     R1,TERM_CURSOR
                STOR    M[R1],R4
                DEC     R5
                CMP     R5,R0
                BR.P    .strloop
                BR      .incursor  
                
;------------------SALTO---------------------
;=============================================================================
;FUNCAO RESPONSAVEL PELA EXECUCAO DO SALTO QUANDO A VARIAVEL FASESALTO É
;DIFERENTE DE 0.O SALTO É TRIGGERED PELO USO DA TECLA KEYUP
;============================================================================
                
SALTO:          MVI     R2,FASESALTO
                LOAD    R4,M[R2]
                CMP     R4,R0
                BR.N    .descida
                
.subida:        MVI     R2,POSDINO
                LOAD    R4,M[R2]
                INC     R4
                STOR    M[R2],R4
                MVI     R5,5
                CMP     R4,R5
                BR.Z    .setdescida
                JMP     R7
.setdescida:    MVI     R2,FASESALTO
                LOAD    R4,M[R2] 
                NEG     R4
                STOR    M[R2],R4
                JMP     R7
                
.descida:       MVI     R2,POSDINO
                LOAD    R4,M[R2]
                DEC     R4
                STOR    M[R2],R4
                MVI     R5,1
                CMP     R4,R5
                BR.Z    .setfim
                JMP     R7
.setfim:        MVI     R2,FASESALTO
                MVI     R4,0
                STOR    M[R2],R4
                JMP     R7
;-----------------COLISAO---------------------- 
;============================================================================
;FUNCAO RESPONSAVEL PELO FIM DO JOGO CASO HAJA COLISAO DO DINOSSAURO E DOS
;CACTOS
;============================================================================
COLISAO:        MVI     R2,VETOR
                INC     R2
                INC     R2
                INC     R2
                INC     R2         ;O dinossauro esta na coluna 05
                INC     R2
                LOAD    R4,M[R2]
                CMP     R4,R0
                BR.Z    .fimcolisao
                MVI     R2,POSDINO
                LOAD    R5,M[R2]
                CMP     R5,R4
                BR.P    .fimcolisao
                ;RESET VARIAVEIS
                MVI     R1,TIMER_CONTROL
                STOR    M[R1],R0
                MVI     R1,GAMEONOFF
                MVI     R2,0
                STOR    M[R1],R2
                MVI     R2,TERM_CURSOR ;limpa o terminal 
                MVI     R5,FFFFH
                STOR    M[R2],R5       
                JAL     GMOVER       ;corre a funcao que escreve game over    
                JMP     JOGO
                
.fimcolisao:    JMP     R7
;-----------------RESET DISP-------------------
;==============================================================================
;FUNCAO CHAMADA PELA FUNCAO INTERRUPCAO KEY0,
;RESPONSAVEL PELO RESET DO DISPLAY
;==============================================================================
RESETDISP:      MVI     R1, DISP7SEG_0
                STOR    M[R1],R0
                MVI     R1,UNIDADES
                STOR    M[R1],R0
                MVI     R1, DISP7SEG_1
                STOR    M[R1],R0
                MVI     R1,DEZENAS
                STOR    M[R1],R0
                MVI     R1, DISP7SEG_2
                STOR    M[R1],R0
                MVI     R1,CENTENAS
                STOR    M[R1],R0
                MVI     R1, DISP7SEG_3
                STOR    M[R1],R0
                MVI     R1,MILHARES
                STOR    M[R1],R0
                JMP     R7
                
;-----------------GM OVER-------------------
;==============================================================================
;FUNCAO CHAMADA PELA FUNCAO COLISAO,RESPONSAVEL PELA APARICAO
;DA MENSAGEM 'GAME OVER' NO TERMINAL
;==============================================================================
GMOVER:         MVI     R4,0405H
                MVI     R2,GAMEOVER
.gmoverloop:    MVI     R1,TERM_CURSOR
                STOR    M[R1],R4
                LOAD    R5,M[R2]    ;percorre a string e imprime os caracteres
                CMP     R5,R0          
                BR.Z    .sair
                MVI     R1,TERM_WRITE
                STOR    M[R1],R5
                INC     R4
                INC     R2
                BR      .gmoverloop
.sair:          JMP     R7
                
                
;--------------------PRINT DINO--------------------
;==============================================================================
;FUNCAO RESPONSAVEL POR DAR PRINT NO DINOSSAURO EM QUALQUER POSICAO QUE ELE
;SE ENCONTRE
;==============================================================================
PRINTDINO:      MVI     R4,POSDINO
                LOAD    R2,M[R4]
                MVI     R4,1
                CMP     R2,R4           ;verifica se e preciso mudar de linha
                BR.P    .mudadelinha
                MVI     R5,0605H        
                BR      .print
                
.mudadelinha:   MVI     R4,MDELINHA
                MVI     R5,0 
                DEC     R2
.pdloop:        ADD     R5,R5,R4      ;ciclo que adiciona 0100H a um registo 
                DEC     R2            ; as vezes necessarias
                CMP     R2,R0
                BR.P    .pdloop        
                MVI     R2,0605H      ;o valor obtido(^) e subtraido a posicao 
                SUB     R5,R2,R5      ;default do dino para mudar de linha
                
.print:         MVI     R2,TERM_CURSOR
                STOR    M[R2],R5
                MVI     R2,TERM_WRITE
                MVI     R3,DINO
                LOAD    R4,M[R3]
                STOR    M[R2],R4
                JMP     R7
;--------------------ATUALIZAJOGO---------------------------------------
;==========================================================================
;FUNCAO RESPONSAVEL POR CRIAR OS CACTOS E POR SUA VEZ ATUALIZAR O VETOR 
;COM OS VALOR DOS MESMOS
;==========================================================================
ATUALIZAJOGO:   STOR    M[R6],R7
                INC     R6
                MVI     R3,COLUNAS
                MVI     R2,VETOR
                
ATUALIZAJOGOFM: CMP     R3,R0
                BR.NZ   ATUALIZA
                
                STOR    M[R6],R2
                INC     R6
                JAL     GERACACTO
                DEC     R6
                LOAD    R2,M[R6]
                STOR    M[R2],R3

                
                DEC     R6
                LOAD    R7,M[R6]
                JMP     R7
                
ATUALIZA:       INC     R2
                LOAD    R4,M[R2]  ;Passagem dos cactos de coluna em coluna
                DEC     R2
                STOR    M[R2],R4
                INC     R2
                DEC     R3
                BR      ATUALIZAJOGOFM
                
                
GERACACTO:      MVI     R4,X            ;Semente de valor arbitrario 
                LOAD    R5,M[R4]
                MVI     R4,1            
                AND     R4,R5,R4         ;Dá-nos o valor do bit
                SHRA    R5
                CMP     R4,R0         ;Se o bit for zero salta para a 2 condiçao
                BR.Z    COND2         ;caso contrario alteramos o valor de x
                MVI     R4,B400H
                XOR     R5,R5,R4
                
COND2:          MVI     R4,7333h ;Se x<29491 retorna a altura do cacto a 0
                CMP     R5,R4         ;se nâo efetua um salto para ret2 e retorna
                BR.O    .negative
                BR.N    .negative
                BR      RET2
                
.negative:                       ;a altura do cacto consoante as operaçoes
                MVI     R3,0          ;realizadas
                MVI     R4,X
                STOR    M[R4],R5
                JMP     R7
                
RET2:           MVI     R4,HMAX
                DEC     R4
                AND     R3,R5,R4                
                INC     R3
                MVI     R4,X
                STOR    M[R4],R5
                JMP     R7
;----------------PONTUACAO---------------------------
;=============================================================================
;FUNCAO RESPONSAVEL PELA ATUALIZACAO DA PONTUACAO E PELA SUA ATUALIZACAO NO
;DISPLAY
;============================================================================
PONTUACAO:      MVI     R1,PONTOS
                LOAD    R2,M[R1]
                INC     R2
                STOR    M[R1],R2
                MVI     R1,UNIDADES
                MVI     R2, 9
                LOAD    R3, M[R1]
                CMP     R2, R3
                BR.Z    .dezenas
                INC     R3
                STOR    M[R1], R3
                MVI     R1, DISP7SEG_0
                STOR    M[R1], R3
                JMP     R7

.dezenas:       STOR    M[R1], R0
                MVI     R1, DISP7SEG_0
                STOR    M[R1], R0
                MVI     R1,DEZENAS
                MVI     R2, 9
                LOAD    R3, M[R1]
                CMP     R2, R3
                BR.Z    .centenas
                INC     R3
                STOR    M[R1], R3
                MVI     R1, DISP7SEG_1
                STOR    M[R1], R3
                JMP     R7
                
.centenas:      STOR    M[R1], R0
                MVI     R1, DISP7SEG_1
                STOR    M[R1], R0
                
                MVI     R1, CENTENAS
                MVI     R2, 9
                LOAD    R3, M[R1]
                CMP     R2, R3
                BR.Z    .milhares
                
                INC     R3
                STOR    M[R1], R3
                MVI     R1, DISP7SEG_2
                STOR    M[R1], R3
                JMP     R7
                
                
.milhares:      STOR    M[R1], R0
                MVI     R1, DISP7SEG_2
                STOR    M[R1], R0               

                MVI     R1, MILHARES
                LOAD    R3, M[R1]
                INC     R3
                MVI     R1, DISP7SEG_3
                STOR    M[R1], R3
                
                JMP     R7
  
;----------------------ROTINAS AUXILIARES DE INTERRUPCAO------------------
INI_TIMER:      STOR    M[R6], R1
                INC     R6
                STOR    M[R6], R2
                INC     R6
                
                MVI     R1, TIMER_COUNTER
                MVI     R2, 1      ;0,1 SEGUNDOS
                STOR    M[R1], R2
                MVI     R1, TIMER_CONTROL
                MVI     R2, 1
                STOR    M[R1], R2
                DEC     R6
                LOAD    R2, M[R6]
                DEC     R6
                LOAD    R1, M[R6]
                JMP     R7
;----------------------ROTINAS DE INTERRUPCAO-----------------------------
                ORIG    7F00H
KEY0:           ; SAVE CONTEXT
                STOR    M[R6],R7
                INC     R6
                STOR    M[R6],R1
                INC     R6
                STOR    M[R6],R2
                INC     R6
                STOR    M[R6],R4
                INC     R6
                STOR    M[R6],R5
                INC     R6
                
                ;RESET DO VETOR
                MVI     R4,COLUNAS
                MVI     R5,0
                MVI     R2,VETOR
.revet:         STOR    M[R2],R5
                DEC     R4
                INC     R2
                CMP     R4,R0
                BR.P    .revet
                JAL     RESETDISP
                MVI     R1,GAMEONOFF
                MVI     R2,1
                STOR    M[R1],R2
                ;RESTORE CONTEXT
                DEC     R6
                LOAD    R5,M[R6]
                DEC     R6
                LOAD    R4,M[R6]
                DEC     R6
                LOAD    R2,M[R6]
                DEC     R6
                LOAD    R1,M[R6]
                DEC     R6
                LOAD    R7,M[R6]
                RTI
                
                ORIG    7F30h
KEYUP:          STOR    M[R6],R4
                INC     R6
                STOR    M[R6],R1
                INC     R6
                MVI     R1,FASESALTO
                LOAD    R4,M[R1]
                CMP     R4,R0
                BR.NZ   .fimkey
                MVI     R4,1
                STOR    M[R1],R4
                DEC     R6
                LOAD    R1,M[R6]
                DEC     R6
                LOAD    R4,M[R6]
.fimkey:        RTI
                
                ORIG    7FF0h
THIMER:          
                DEC     R6
                STOR    M[R6], R7
                MVI     R1,GAMEONOFF
                MVI     R2,1
                STOR    M[R1],R2
                JAL     INI_TIMER
                LOAD    R7, M[R6]
                INC     R6
                RTI
             