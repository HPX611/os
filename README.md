# os

启动bochs的命令：``./bin/bochs -f bochsrc.disk``

编译二进制文件：``nasm -I include/ -o loader.bin loader.S``

将文件写到磁盘里：``dd if=./loader.bin of=/home/cdh/os/bochs/hd60M.img bs=512 count=1 seek=2 conv=notrunc``

* if：要烧写的文件
* of：虚拟磁盘的文件
* bs：512
* count：写的磁盘数量
* seek：定位的磁盘位置



## 加载mbr

```cmd
nasm -I include/ -o ../build/mbr mbr.S
dd if=../build/mbr of=/home/cdh/os/bochs/hd60M.img bs=512 count=1 conv=notrunc
```



## 加载loader

```cmd
nasm -I include/ -o ../build/loader loader.S
dd if=../build/loader of=/home/cdh/os/bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc
```



## 启用分页机制

1. 准备好页目录表及页表
2. 将页表地址写入控制寄存器 cr3
3. 寄存器 cr0 的 PG 位置 1



```cmd
ld kernel/main.o -Ttext 0xc0001500 -e main -o kernel/kernel.bin 
```

* -Ttext 指定起始虚拟地址为 0xc0001500
* -e ADDRESS, --entry ADDRESS Set start address  ，用来指定程序的起始地址，用来指定程序从哪里开始执行



## elf文件

| ELF 目标文件类型                   | 描 述                                                        |
| ---------------------------------- | ------------------------------------------------------------ |
| 待重定位文件（relocatable file）   | 待重定位文件就是常说的目标文件，属于源文件编译后但未完成链接的半成品，它被用于与<br/>其他目标文件合并链接，以构建出二进制可执行文件或动态链接库。为什么称其为“待重定<br/>位”文件呢？原因是在该目标文件中，如果引用了其他外部文件（其他目标文件或库文件）<br/>中定义的符号（变量或者函数统称为符号），在编译阶段只能先标识出一个符号名，该符号具<br/>体的地址还不能确定，因为不知道该符号是在哪个外部文件中，而该外部文件需要被重定位<br/>后才能确定文件内的符号地址，这些重定位的工作是需要在连接的过程中完成的 |
| 共享目标文件（shared object file） | 这就是我们常说的动态链接库。在可执行文件被加载的过程中被动态链接，成为程序代码的<br/>一部分 |
| 可执行文件（executable file ）     | 经过编译链接后的、可以直接运行的程序文件                     |

![image-20241008064836535](/home/cdh/os/project/README.assets/image-20241008064836535.png)

elf使用程序头表（program header table）和节头表（section header table）

程序头表：存储多个程序头program header，也就是程序的段

节头表：存储多个节头section header，也就是节

ELF header，它位于文件最开始的部分，并具有固定大小，用来描述程序头表和节头表的大小及位置信息

