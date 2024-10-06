# os

启动bochs的命令：``./bin/bochs -f bochsrc.disk``

编译二进制文件：``nasm -I include/ -o loader.bin loader.S``

将文件写到磁盘里：``dd if=./loader.bin of=/home/cdh/os/bochs/hd60M.img bs=512 count=1 seek=2 conv=notrunc``

* if：要烧写的文件
* of：虚拟磁盘的文件
* bs：512
* count：写的磁盘数量
* seek：定位的磁盘位置



加载mbr

```cmd
nasm -I include/ -o mbr.bin mbr.S
dd if=./mbr.bin of=/home/cdh/os/bochs/hd60M.img bs=512 count=1 conv=notrunc
```



加载loader

```cmd
nasm -I include/ -o loader.bin loader.S
dd if=./loader.bin of=/home/cdh/os/bochs/hd60M.img bs=512 count=4 seek=2 conv=notrunc
```



