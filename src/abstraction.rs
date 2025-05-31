use core::cell::UnsafeCell;
use core::ptr::{read_volatile, write_volatile};

pub struct Register(UnsafeCell<u32>);
impl Register {
    pub const fn new() -> Self {
        // These are always placed NOLOAD by the linker, so this value is never actually used
        Register(UnsafeCell::new(0))
    }
    pub unsafe fn modify(&self, mask: u32, val: u32) -> () {
        let mut x = unsafe { read_volatile(self.0.get()) };
        x &= !mask;
        x |= val;
        unsafe { write_volatile(self.0.get(), x) };
    }
}

pub unsafe fn calculate_mask(lsb: u8, size: u8) -> u32 {
    let mask: u32 = (1 << size) - 1;
    mask << lsb
}
