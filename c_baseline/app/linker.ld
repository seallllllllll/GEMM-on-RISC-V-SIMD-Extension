OUTPUT_ARCH("riscv")
ENTRY(_start)

SECTIONS
{
  /* Program entry address (IMEM base) */
  . = 0x00000000;

  .text : {
    *(.text._start)
    *(.text*)
  }

  .rodata : { *(.rodata*) }

  .data : { *(.data*) }

  .bss : {
    __bss_start = .;
    *(.bss*) *(COMMON)
    __bss_end = .;
  }

  .stack (NOLOAD) : {
    . = ALIGN(16);
    . += 4096;        /* 4KB stack */
    __stack_top = .;
  }
}
