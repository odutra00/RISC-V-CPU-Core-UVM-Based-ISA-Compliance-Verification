# Inicializa vetor[0..9] com valores de 0 a 9
# depois soma esses 10 valores (resultado esperado = 45)

.equ RAM_BASE,  0x80000 #0x00000060

# =========================================================
# SEÇÃO DE DADOS (Aqui ficam apenas variáveis)
# =========================================================
.section .data
.align 4
ram:
    .space 16              

.align 8
.global tohost
.global fromhost
tohost:   .dword 0
fromhost: .dword 0


# =========================================================
# SEÇÃO DE TEXTO / CÓDIGO (MUITO IMPORTANTE!)
# =========================================================
.section .text         # <-- ESTA LINHA ESTAVA FALTANDO AQUI!
.global start

start:
    addi t0, x0, 10        # contador do loop de soma
    addi t1, x0, 0         # acumulador
    # CARREGAMENTO DO ENDEREÇO REAL (Sem gambiarra!)
    lui  t2, RAM_BASE       # t2 = 0x80001000 (Carrega os 20 bits superiores)
    # Se o offset da RAM fosse diferente, usaria: addi t2, t2, offset
    addi t4, x0, 10        # contador de inicialização
    nop
    nop

# --------------------------------
# inicializa ram[0..9] = 9..0
# --------------------------------
init_mem:
    beq  t4, x0, loop
    addi t4, t4, -1
    nop
    nop
    add  t3, t2, t4        # t3 = &ram + t4
    nop
    nop
    sb   t4, 0(t3)         # ram[t4] = t4
    beq  x0, x0, init_mem

# --------------------------------
# soma os 10 valores
# --------------------------------
loop:
    beq  t0, x0, end
    lb   t3, 0(t2)         # lê ram[i]
    nop
    nop
    add  t1, t1, t3
    addi t2, t2, 1
    addi t0, t0, -1
    nop
    nop
    beq  x0, x0, loop

# --------------------------------
# teste jal / jalr
# --------------------------------
end:
    jal  ra, subrotina

after_return:
    nop
    # Em vez de ecall (que precisa do PK), usamos loop de fim de teste
    j    shutdown

subrotina:
    addi t5, x0, 123
    nop
    jalr x0, 0(ra)

shutdown:
    j    shutdown          # O Spike vai ficar preso aqui girando no mesmo PC
