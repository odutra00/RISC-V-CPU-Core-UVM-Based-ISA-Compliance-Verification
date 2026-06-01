ENTRY(start)

MEMORY
{
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 0x00020000
}

SECTIONS
{
    . = 0x80000000;
    
    .text : { 
        *(.text) 
        *(.text*) 
    } > RAM

    .data : { 
        *(.data) 
        *(.data*) 
        *(.tohost)
    } > RAM

    /DISCARD/ : { *(.note.gnu.build-id) *(.comment) *(.eh_frame) *(.riscv.attributes) }
}
