# Workaround for https://github.com/rust-lang/rust/issues/127269
.fpu vfpv3-d16

.macro CREATE_FRAME
	PUSH {{r0-r3}}
	VPUSH {{d0-d7}}
	VMRS r0, FPSCR
	VMRS r1, FPEXC
	# 8-byte align stack
	MOV r2, sp
	AND r2, 7
	SUB sp, r2
	# Store 4x 4 byte registers to retain 8-byte alignment
	PUSH {{r0-r2,r12}}
.endm

.macro DESTROY_FRAME
	POP {{r0-r2,r12}}
	ADD sp, r2
	VMSR FPEXC, r1
	VMSR FPSCR, r0
	VPOP {{d0-d7}}
	POP {{r0-r3}}
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
	B reset_handler
	B undefined_instruction_handler
	B software_interrupt_handler
	B abort_prefetch_handler
	B abort_data_handler
	NOP
	B irq_handler
fiq_handler:
	# Adjust LR to instruction following instruction boundary at which the
	# exception was taken
	# ARM Architecture Reference Manual ARMv7-A and ARMv7-R edition
	# B1.9.12 - FIQ exception
	# Page B1-1221
	SUBS lr, 4
	SRSFD sp!, 0b10001
	CREATE_FRAME
	BL _fiq_handler
	DESTROY_FRAME
	RFEFD sp!

.section .text
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

undefined_instruction_handler:
	# Spin.  This should be changed if undefined instructions are handled
undef_spin:
	B undef_spin

software_interrupt_handler:
	SRSFD sp!, 0b10011
	CREATE_FRAME
	# Ignore SVC vector number, since that would require loading the
	# calling instruction into data cache
	# assume that the arguments to the SVC handler are passed in r0-r3
	BL _svc_handler
	DESTROY_FRAME
	RFEFD sp!

abort_prefetch_handler:
	# Adjust LR to aborting instruction
	# ARM Architecture Reference Manual ARMv7-A and ARMv7-R edition
	# B1.9.7 - Prefetch Abort exception
	# Page B1-1212
	SUBS lr, 4
	SRSFD sp!, 0b10111
	CREATE_FRAME
	# Pass address of aborting instruction to handler
	MOV r0, lr
	BL _abort_prefetch_handler
	DESTROY_FRAME
	RFEFD sp!

abort_data_handler:
	# Adjust LR to aborting instruction
	# ARM Architecture Reference Manual ARMv7-A and ARMv7-R edition
	# B1.9.8 - Data Abort exception
	# Page B1-1212
	SUBS lr, 8
	SRSFD sp!, 0b10111
	CREATE_FRAME
	# Pass address of aborting instruction to handler
	MOV r0, lr
	BL _abort_data_handler
	DESTROY_FRAME
	RFEFD sp!

irq_handler:
	# Adjust LR to instruction following instruction boundary at which the
	# exception was taken
	# ARM Architecture Reference Manual ARMv7-A and ARMv7-R edition
	# B1.9.10 - IRQ exception
	# Page B1-1218
	SUBS lr, 4
	SRSFD sp!, 0b10010
	CREATE_FRAME
	BL _irq_handler
	DESTROY_FRAME
	RFEFD sp!
