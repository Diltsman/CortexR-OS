ENTRY(reset_handler)

STACK_SIZE = 128;

MEMORY {
  tcm_flash(rx) : ORIGIN = 0x00000000, LENGTH = 1280K
  tcm_ram(!rx)  : ORIGIN = 0x08000000, LENGTH =  192K

  sys(w)        : ORIGIN = 0xffffff00, LENGTH = 0xfc
}

SECTIONS {
  .vector_table ORIGIN(tcm_flash) : {
    #ASSERT(. == 0x00000000, ".vector_table must be at the beginning of flash");
    __vector_table_start = .;
    KEEP(*(.vector_table));
    *(.vector_table);
    __vector_table_end = .;
  } > tcm_flash

  .text : {
    __text_start = .;
    *(.text .text*);
    __text_end = .;
  } > tcm_flash

  .rodata : {
    . = ALIGN(8);
    *(.rodata .rodata*);
    . = ALIGN(8);
  } > tcm_flash

  .data : ALIGN(32) {
    . = ALIGN(32);
    __data_start = .;
    *(.data .data*);
    . = ALIGN(32);
    __data_end = .;
  } > tcm_flash AT>tcm_ram

  __data_start_ram = LOADADDR(.data);

  .bss : ALIGN(32) {
    . = ALIGN(32);
    __bss_start = .;
    *(.bss .bss*);
    . = ALIGN(32);
    __bss_end = .;
  } > tcm_ram

  .stacks (NOLOAD) : ALIGN(8) {
    . = ALIGN(8);
    __und_stack_start = .;
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __und_stack_end = .;

    . = ALIGN(8);
    __svc_stack_start = .;
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __svc_stack_end = .;

    . = ALIGN(8);
    __abt_stack_start = .;
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __abt_stack_end = .;

    . = ALIGN(8);
    __irq_stack_start = .;
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __irq_stack_end = .;

    . = ALIGN(8);
    __fiq_stack_start = .;
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __fiq_stack_end = .;

    . = ALIGN(8);
    __sys_stack_start = .;
    . = . + STACK_SIZE;
    . = ALIGN(8);
    __sys_stack_end = .;
  } > tcm_ram

  .sys (NOLOAD) : {
    __sys_start = .;
    *(.sys .sys*);
    __sys_end = .;
  } > sys
}

ASSERT(__sys_end - __sys_start == 0xfc, "SYS must be 0xfc bytes long (63x 32-bit ints)");
