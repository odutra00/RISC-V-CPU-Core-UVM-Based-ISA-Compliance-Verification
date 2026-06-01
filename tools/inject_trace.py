#!/usr/bin/env python3
from pathlib import Path
import re

CPP_FILE   = "dv/dpi/spike_dpi.cc"
TRACE_FILE = "assembly/trace_pushBack.log"

cpp   = Path(CPP_FILE).read_text()
trace = Path(TRACE_FILE).read_text()

pattern = r'// TRACE BEGIN.*?// TRACE END'

replacement = f"""// TRACE BEGIN
{trace}
// TRACE END"""

new_cpp = re.sub(pattern, replacement, cpp, flags=re.S)

Path(CPP_FILE).write_text(new_cpp)

print("Trace atualizado.")
