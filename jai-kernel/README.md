# Kernel

A toy kernel that may or may not work.

The kernel is currently built to be loaded with a Multiboot compliant bootloader, in
this case that is grub. This will change eventually where I want to write my own bootloader.

## Running

    $ ./build.sh
    $ qemu-system-x86_64 -cdrom builds/kernel.iso

## Bootloader

When you turn on a computer, it begins executing firmware code that is stored in motherboard ROM. This code performs a power-on self-test, detects available RAM, and pre-initializes the CPU and hardware. Afterwards, it looks for a bootable disk and starts booting the operating system kernel.

On x86, there are two firmware standards: the “Basic Input/Output System“ (BIOS) and the newer “Unified Extensible Firmware Interface” (UEFI). The BIOS standard is old and outdated, but simple and well-supported on any x86 machine since the 1980s. UEFI, in contrast, is more modern and has much more features, but is more complex to set up.

## Resources

- https://github.com/vishen/go-bootloader/blob/master/main.go
- https://en.wikipedia.org/wiki/GNU_GRUB
- https://wiki.osdev.org/GRUB_2
- https://wiki.osdev.org/Multiboot
- https://wiki.osdev.org/Rolling_Your_Own_Bootloader
- https://wiki.osdev.org/Bare_bones
- https://os.phil-opp.com/multiboot-kernel/
- https://os.phil-opp.com/minimal-rust-kernel/
- https://github.com/rust-osdev/bootloader
- https://www.gnu.org/software/grub/manual/multiboot2/multiboot.html
- https://github.com/croemheld/elfboot/
