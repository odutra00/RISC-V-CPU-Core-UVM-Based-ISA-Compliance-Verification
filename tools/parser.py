import re
import subprocess

OBJDUMP = "/opt/riscv/bin/riscv64-unknown-elf-objdump"
ELF_FILE  = "assembly/main.elf"
TRACE_LOG = "assembly/trace.log"

# sem pk relocando e compensando endereço base de alocação do Spike
BASE = 0x80000000


# ==========================================================
# Descobre automaticamente o último PC do .text
# ==========================================================

objdump_out = subprocess.check_output(
    [OBJDUMP, "-d", ELF_FILE],
    text=True
)

last_pc = None

for line in objdump_out.splitlines():
    # casa:
    #  2c: fe0000e3 ...
    m = re.match(r'^\s*([0-9a-fA-F]+):', line)
    if m:
        last_pc = int(m.group(1), 16)

if last_pc is None:
    raise RuntimeError("Não encontrei instruções em main.elf")

START = BASE
END   = BASE + last_pc + 4

#print(f"START = 0x{START:08x}")
#print(f"END   = 0x{END:08x}")
#print()


# ==========================================================
# Parse do trace do Spike
# ==========================================================
pattern = re.compile(
    r'core\s+\d+:\s+\d+\s+'
    r'0x([0-9a-fA-F]+)\s+'
    r'\(0x([0-9a-fA-F]+)\)\s+'
    r'x(\d+)\s+'
    r'0x([0-9a-fA-F]+)'
)

with open(TRACE_LOG) as f:
    for line in f:

        m = pattern.search(line)
        if not m:
            continue

        pc = int(m.group(1), 16)

        if not (START <= pc < END):
            continue

        instr = int(m.group(2), 16)
        rd    = int(m.group(3))
        data  = int(m.group(4), 16)

        # JAL escreve PC+4 em rd
        # Spike usa endereço absoluto
        # DUT usa endereço relativo
        if rd != 0 and (instr & 0x7f) == 0x6f and data >= BASE:
            data -= BASE

        pc -= BASE

        print(
            f'trace.push_back({{true, '
            f'0x{pc:08x}ULL, '
            f'0x{instr:08x}u, '
            f'{rd}, '
            f'0x{data:08x}ULL, '
            f'false, 0, 0, false, 3}});'
        )









