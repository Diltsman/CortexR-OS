.macro NOP_MAC
	LDR pc, =reset_handler
.endm

.extern __und_stack_end
.extern __svc_stack_end
.extern __abt_stack_end
.extern __irq_stack_end
.extern __fiq_stack_end
.extern __sys_stack_end

.extern __bss_start
.extern __bss_end
.extern __data_start
.extern __data_end
.extern __data_start_ram

.section .vector_table,"ax"
	LDR pc, =reset_handler
	LDR pc, =undefined_instruction_handler
	LDR pc, =software_interrupt_handler
	LDR pc, =abort_prefetch_handler
	LDR pc, =abort_data_handler
	NOP
	LDR pc, =irq_handler
yyy:
	B yyy

.section .text
undefined_instruction_handler:
software_interrupt_handler:
abort_prefetch_handler:
abort_data_handler:
irq_handler:
	B irq_handler

reset_handler:
	# UND - 0x1B - Undefined
	# I = 1, F = 1
	LDR r0, =0x000000db
	MSR cpsr, r0
	LDR sp, =__und_stack_end

	# SVC - 0x13 - Supervisor
	# I = 1, F = 1
	LDR r0, =0x000000d3
	MSR cpsr, r0
	LDR sp, =__svc_stack_end

	# ABT - 0x17 - Abort
	LDR r0, =0x000000d7
	MSR cpsr, r0
	LDR sp, =__abt_stack_end

	# IRQ - 0x12 - IRQ
	LDR r0, =0x000000d2
	MSR cpsr, r0
	LDR sp, =__irq_stack_end

	# FIQ - 0x11 - FIQ
	LDR r0, =0x000000d1
	MSR cpsr, r0
	LDR sp, =__fiq_stack_end

	# SYS - 0x1f - System
	LDR r0, =0x000000df
	MSR cpsr, r0
	LDR sp, =__sys_stack_end

	# Initialize VFPv3
	LDR r0, =0x00f00000
	MCR p15, 0, r0, c1, c0, 2
	LDR r0, =0x40000000
	VMSR fpexc, r0

	# Initialize .bss
	MOV r0, 0
	MOV r1, 0
	MOV r2, 0
	MOV r3, 0
	MOV r4, 0
	MOV r5, 0
	MOV r6, 0
	MOV r7, 0
	LDR r8, =__bss_start
	LDR r9, =__bss_end
bss_next:
	CMP r8, r9
	BGE bss_done
	STMIA r8!,{{r0-r7}}
	B bss_next
bss_done:

	# Initialize .data
	LDR r8, =__data_start
	LDR r9, =__data_end
	LDR r10, =__data_start_ram
data_next:
	CMP r8, r9
	BGE data_done
	LDMIA r8!, {{r0-r7}}
	STMIA r10!, {{r0-r7}}
	B data_next
data_done:
	BL _start
reset_spin:
	B reset_spin
