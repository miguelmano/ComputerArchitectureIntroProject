;Realizado Por Miguel Mano Nº99286
;e Stanislaw Talejko Nº99330

VETOR           EQU     4000H
COLUNAS         EQU     20
                
                ORIG    2000H
X               WORD    5

                ORIG    0000H
                
                MVI     R6,VETOR          
                MVI     R1,COLUNAS
                

                JAL     ATUALIZAJOGO
FIM:            BR      FIM

ATUALIZAJOGO:   CMP     R1,R0
                BR.NZ   ATUALIZA
                JAL     GERACACTO
                STOR    M[R6],R3
                
                MVI     R6,VETOR      ;Reinicia o vetor e o counter de modo a     
                MVI     R1,COLUNAS   ;puxar sucessivamente os valores dos cactos   
                
                
ATUALIZA:       INC     R6
                LOAD    R2,M[R6]  ;Passagem dos cactos de coluna em coluna
                DEC     R6
                STOR    M[R6],R2
                INC     R6
                DEC     R1
                BR      ATUALIZAJOGO
                
                
GERACACTO:      MVI     R4,X            ;Semente de valor arbitrario 
                LOAD    R5,M[R4]
                MVI     R4,1
                AND     R4,R5,R4         ;Dá-nos o valor do bit
                SHRA    R5
                CMP     R4,R0         ;Se o bit for zero salta para a 2 condiçao
                BR.Z    COND2         ;caso contrario alteramos o valor de x
                MVI     R4,B400H
                XOR     R5,R5,R4
                
COND2:          MVI     R4,7333h      ;Se x<29491 retorna a altura do cacto a 0
                CMP     R5,R4         ;se nâo efetua um salto para ret2 e retorna
                BR.NN   RET2          ;a altura do cacto consoante as operaçoes
                MVI     R3,0          ;realizadas
                MVI     R4,X
                STOR    M[R4],R5
                JMP     R7
                
RET2:           MVI     R4,4
                DEC     R4
                AND     R3,R5,R4                
                INC     R3
                MVI     R4,X
                STOR    M[R4],R5
                JMP     R7
                
                
             