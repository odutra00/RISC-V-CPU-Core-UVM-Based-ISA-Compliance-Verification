#Inicializa as 10 primeiras posiçoes da ram (0 a 9) com dados de 0 a 9
#depois soma os dados desses 10 endereços (resultado 45)
start:
    addi t0, x0, 10     #t0 contador auxiliar de controle de loop
    addi t1, x0, 0      #t1 recebe as somas dos valores
    addi t2, x0, 0x0000 #t2 é o ponteiro para 
    addi t4, x0, 10     #t4 recebe 10 (valor e posicao na ram)
    nop
    nop
init_mem: #inicializa memoria
    beq t4, x0, loop    # se t4 == 0 -> vai pra loop fazer as somas
    addi t4, t4, -1     #decrementa 1 de t4 e salva em t4
    nop                 #bolhas
    nop
    sb t4, 0(t4)        #salva t4 em M[[t4]+0]
    beq x0, x0, init_mem #Vai para init_mem sempre
loop:
    beq t0, x0, end     # se contador == 0 -> sai antes de ler
    lb t3, 0(t2)        #Carrega valor da memoria em t2 (x28 <= mem[0+[x7]])
    nop                 #Bolha (addi x0, x0, 0)
    nop                 #Bolha (addi x0, x0, 0)
    add t1, t1, t3      #Soma recursiva em t1 (x6 <- [x6] + [x28])
    addi t2, t2, 1      #Incrementa ponteiro t2 (x7 <- [x7 + 1])
    addi t0, t0, -1     #Descrementa contador auxiliar de controle do loop (x5 <- [x5] + 1)
    beq x0, x0, loop    #Vai para loop sempre
end:
    addi x0, x0, 0      #nop
    beq x0, x0, start   #loop infinito para inicio do programa
    
MEMORY
{   ROM (rx) : ORIGIN = 0x00000000 , LENGTH = 0x00090
    RAM (rwx) : ORIGIN = 0x00000000 , LENGTH = 0x00018
}
SECTIONS
{ 
    .text :
    {
        *(. boot)
        *(. text*)
        *(. rodata *)
        _etext = .; /* Fim do código na ROM */
    } > ROM
}