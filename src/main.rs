#![no_std]
#![no_main]

use core::{arch::global_asm, panic::PanicInfo, u32};

global_asm!(include_str!("handlers.S"));

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn _start() -> () {
    loop {}
}

#[unsafe(no_mangle)]
pub extern "C" fn _svc_handler() -> () {}

#[unsafe(no_mangle)]
#[allow(unused_variables)]
pub extern "C" fn _abort_prefetch_handler(instruction_addr: u32) -> () {}

#[unsafe(no_mangle)]
#[allow(unused_variables)]
pub extern "C" fn _abort_data_handler(instruction_addr: u32) -> () {}

#[unsafe(no_mangle)]
pub extern "C" fn _irq_handler() -> () {}

#[unsafe(no_mangle)]
pub extern "C" fn _fiq_handler() -> () {}
