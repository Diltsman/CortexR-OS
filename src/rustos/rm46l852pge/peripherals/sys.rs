use core::ptr::{read_volatile, write_volatile};

#[unsafe(link_section = ".sys")]
static mut SYS: [u32; 0xFC / 4] = [0; 0xfc / 4];

pub fn set_pena() -> () {
    let y = unsafe { &raw const (SYS[0xd0 / 4]) };
    let mut x: u32 = unsafe { read_volatile(y) };
    x |= 0x100;
    let y = unsafe { &raw mut (SYS[0xd0 / 4]) };
    unsafe { write_volatile(y, x) };
}
