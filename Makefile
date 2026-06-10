#################################################
# USO
# make asm
# make hex
# make trace
# make sim
# make gui
# make full
# make clean

#make run
#monta program.asm → main.elf
#gera main.hex
#roda Spike
#gera trace.log
#parseia para trace_pushBack.log
#injeta no spike_dpi.cc
#pronto para rodar UVM
#################################################

#################################################
# TOOLCHAIN RISC-V
#################################################
AS      = /opt/riscv/bin/riscv64-unknown-elf-as
LD      = /opt/riscv/bin/riscv64-unknown-elf-ld
CC      = /opt/riscv/bin/riscv64-unknown-elf-gcc
OBJCOPY = /opt/riscv/bin/riscv64-unknown-elf-objcopy
OBJDUMP = /opt/riscv/bin/riscv64-unknown-elf-objdump
SPIKE   = /opt/riscv/bin/spike
# PK    = /opt/riscv/riscv64-unknown-elf/bin/pk

#################################################
# DIRETÓRIOS / ARQUIVOS
#################################################
ASM_DIR = assembly

SRC      = $(ASM_DIR)/program.asm  
LDFILE   = $(ASM_DIR)/link.ld  
OBJ      = $(ASM_DIR)/main.o
ELF      = $(ASM_DIR)/main.elf
#HEX      = $(ASM_DIR)/main.hex
HEX_TEXT = $(ASM_DIR)/main_text.hex
HEX_DATA = $(ASM_DIR)/main_data.hex
TRACE    = $(ASM_DIR)/trace.log
PUSHBK   = $(ASM_DIR)/trace_pushBack.log

#################################################
# FLAGS
#################################################
ASFLAGS = -march=rv32i -mabi=ilp32
# LDFLAGS = -m elf32lriscv -N -T $(LDFILE)
LDFLAGS = -march=rv32i -mabi=ilp32 -nostdlib -T $(LDFILE)

#################################################
# XRUN / UVM
#################################################
XRUN = xrun

UVM_HOME = /apps/cds/XCELIUM2409/tools.lnx86/methodology/UVM/CDNS-1.2

XRUN_FLAGS = \
	-uvmhome $(UVM_HOME) \
	-uvm \
	-sv \
	-64bit \
	-access +rwc \
	-timescale 1ns/1ns \
	-clean \
	-NOWARN DLCPTH \
	-incdir dv/include \
	-incdir dv/if \
	-incdir dv/scoreboard \
	-dpi

FILELIST = filelist.f

#################################################
# DEFAULT
#################################################
.PHONY: all
all: asm

#################################################
# ASM
#################################################
.PHONY: asm
asm: $(ELF)

$(OBJ): $(SRC)
	$(AS) $(ASFLAGS) -o $@ $<

$(ELF): $(OBJ)
	$(CC) $(LDFLAGS) -o $@ $<
	# $(LD) $(LDFLAGS) -o $@ $<

################################################
# HEX
#################################################
.PHONY: hex
hex: $(ELF)
	# $(OBJCOPY) -O ihex $< $(HEX_TEXT)
	# $(OBJCOPY) -O ihex $< $(HEX_DATA)
	# $(OBJCOPY) -O ihex -j .text $(ELF) $(HEX_TEXT)
	# $(OBJCOPY) -O ihex -j .data $(ELF) $(HEX_DATA)
	# $(OBJCOPY) -O verilog -j .text $(ELF) $(HEX_TEXT) #em byte, little endian
	# $(OBJCOPY) -O verilog -j .data $(ELF) $(HEX_DATA)

	$(OBJDUMP) -d $(ELF) | \
	awk '/^[[:space:]]*[0-9a-f]+:/ {print $$2}' \
	> $(HEX_TEXT)

	$(OBJDUMP) -s -j .data $(ELF) | \
	awk '/^[[:space:]]+[0-9a-fA-F]{4,}/ { \
		for(i=2;i<=NF;i++) \
			if($$i ~ /^[0-9a-fA-F]{8}$$/) { \
				printf "%s\n", substr($$i,7,2) substr($$i,5,2) substr($$i,3,2) substr($$i,1,2) \
			} \
	}' > $(HEX_DATA)


#################################################
# TRACE
#################################################
.PHONY: trace
trace: $(ELF)
	@echo "Running Spike in background..."
	# Roda o Spike em segundo plano (&) e salva o ID do processo ($!)
	@$(SPIKE) --isa=RV32IM_ZICSR_ZIFENCEI \
	          --log-commits \
	          $(ELF) > $(TRACE) 2>&1 & \
	          SPIKE_PID=$$! ; \
	          sleep 2 ; \
	          echo "Stopping Spike (PID $$SPIKE_PID)..." ; \
	          kill -9 $$SPIKE_PID || true
	@echo "Parsing trace..."
	@python3.12 ./tools/parser.py > $(PUSHBK)
	@echo "Done: $(PUSHBK)"

#################################################
# injeta trace no DPI
#################################################
.PHONY: inject
inject: trace
	python3.12 ./tools/inject_trace.py

#################################################
# RUN (asm + hex + trace)
#################################################
.PHONY: run
run: asm hex trace inject

#################################################
# SIM UVM
#################################################
.PHONY: sim
sim: $(ELF)
	$(XRUN) $(XRUN_FLAGS) \
	-f $(FILELIST) \
	-top riscv_tb_top \
	+UVM_TESTNAME=smoke_test \
	+UVM_NO_RELNOTES \
	+elf=$(ELF) \
	-l sim.log

#################################################
# GUI
#################################################
.PHONY: gui
gui: $(ELF)
	$(XRUN) $(XRUN_FLAGS) \
	-f $(FILELIST) \
	-top riscv_tb_top \
	-gui \
	+UVM_TESTNAME=smoke_test \
	+UVM_NO_RELNOTES \
	+elf=$(ELF) \
	-l sim.log \
	-input "@database -open waves -into waves.shm -default; probe -create -all -depth all; run"

#################################################
# FULL FLOW
#################################################
.PHONY: full
full: run sim

#################################################
# CLEAN
#################################################
.PHONY: clean
clean:
	rm -rf xrun.history
	rm -rf xcelium.d
	rm -rf INCA_libs
	rm -rf worklib
	rm -f *.log *.key *.shm *.vcd *.vpd
	rm -f $(ASM_DIR)/*.elf
	rm -f $(ASM_DIR)/*.o
	rm -f $(ASM_DIR)/*.hex
	rm -f $(ASM_DIR)/*.log
