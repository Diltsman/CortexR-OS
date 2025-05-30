use core::ptr::{read_volatile, write_volatile};

#[repr(C)]
struct SysStruct {
    registers: [u32; 0xfc / 4],
}

// Init is required by Rust, but isn't used due to linker script NOLOAD
#[unsafe(link_section = ".sys")]
static mut SYS: SysStruct = SysStruct {
    registers: [0; 0xfc / 4],
};

pub fn set_pena() -> () {
    let offset = 0xd0 / 4;
    let y = unsafe { &raw mut (SYS.registers[offset]) };
    let mut x: u32 = unsafe { read_volatile(y) };
    x |= 0x100;
    unsafe { write_volatile(y, x) };
}
