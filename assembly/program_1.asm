#Inicializa as 10 primeiras posiçoes da ram (0 a 9) com dados de 0 a 9
#depois soma os dados desses 10 endereços (resultado 45)
#Devido ao emulador SPIKE nao considerar arquitetura Harvard, 
#não podemos inicializar a RAM a partir de 0. Caso contrário,
#na execução do SPIKE, escritas em memória sobreescreverão o programa.

.equ RAM_BASE, 0x00000200

start:
    addi t0, x0, 10
    addi t1, x0, 0
    addi t2, x0, RAM_BASE
    addi t4, x0, 10
    nop
    nop

init_mem: #24
    beq  t4, x0, loop 
    addi t4, t4, -1
    nop
    nop
    sb   t4, RAM_BASE(t4)
    beq  x0, x0, init_mem

loop: #48
    beq  t0, x0, end
    lb   t3, 0(t2)
    nop
    nop
    add  t1, t1, t3
    addi t2, t2, 1
    addi t0, t0, -1
    beq  x0, x0, loop

# -------------------------
# TESTE JAL / JALR
# -------------------------
end: #80
    jal  ra, subrotina      # salva PC+4 em x1(ra = return address) e salta

after_return:#84
    nop                     # deve voltar aqui
    beq  x0, x0, start


subrotina:#92
    addi t5, x0, 123        # instrução qualquer p/ debug
    nop
    jalr x0, 0(ra)          # retorna usando x1


