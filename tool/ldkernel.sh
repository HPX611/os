#!/bin/bash
cd /home/cdh/os/project


# 编译mbr并写入磁盘
nasm -I boot/include/ -o build/mbr boot/mbr.S
dd if=build/mbr of=/home/cdh/os/bochs/hd60M.img bs=512 count=1 conv=notrunc

# 编写loader并写入磁盘
nasm -I boot/include/ -o build/loader boot/loader.S
dd if=build/loader of=/home/cdh/os/bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc

# 编译print文件
nasm -f elf -o build/print.o lib/kernel/print.S -I lib/

# 编译kernel文件
nasm -f elf -o build/kernel.o kernel/kernel.S 

# 编译interrupt文件
gcc-4.4 -c -o build/interrupt.o kernel/interrupt.c -m32 -I lib/kernel/ -I lib/ -I kernel/

# 编译init文件
gcc-4.4 -c -o build/init.o kernel/init.c -m32 -I lib/kernel/ -I lib/ -I kernel/

# 编译kernel文件并写入磁盘
gcc-4.4 -c -o build/main.o kernel/main.c -m32 -I lib/kernel/ -I lib/ -I kernel/
ld build/main.o build/init.o build/interrupt.o build/print.o build/kernel.o -Ttext 0xc0001500 -e main -o build/kernel.bin -m elf_i386
dd if=build/kernel.bin of=/home/cdh/os/bochs/hd60M.img bs=512 count=200 seek=9 conv=notrunc