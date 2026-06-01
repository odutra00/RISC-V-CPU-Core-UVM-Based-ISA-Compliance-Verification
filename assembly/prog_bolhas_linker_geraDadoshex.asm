.section .text
.global start
start:
    addi t0, x0, 10     #t0 contador auxiliar de controle de loop
    addi t1, x0, 0      #t1 recebe as somas dos valores
    addi t2, x0, 0x0000 #t2 é o ponteiro para 
loop:
    beq t0, x0, end     # se contador == 0 -> sai antes de ler
    lw t3, 0(t2)        #Carrega valor da memoria em t2 (x28 <= mem[0+[x7]])
    nop                 #Bolha (addi x0, x0, 0)
    nop                 #Bolha (addi x0, x0, 0)
    nop                 #Bolha (addi x0, x0, 0)
    add t1, t1, t3      #Soma recursiva em t1 (x6 <- [x6] + [x28])
    addi t2, t2, 1      #Incrementa ponteiro t2 (x7 <- [x7 + 1])
    addi t0, t0, -1     #Descrementa contador auxiliar de controle do loop (x5 <- [x5] + 1)
    beq x0, x0, loop    #Vai para loop sempre
end:
    addi x0, x0, 0      #nop
    #beq x0, x0, start   #loop infinito para inicio do programa

.section .data
vetor:
    .word 0
    .word 1
    .word 2
    .word 3
    .word 4
    .word 5
    .word 6
    .word 7
    .word 8
    .word 9

