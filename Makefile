#文件夹
BUILD_DIR=./build
#kernel进入的地址
ENTRY_POINT = 0xc0001500
#硬盘的绝对地址
HD60M_PATH=/home/cdh/os/bochs/hd60M.img	

#编译的工具
AS = nasm
CC = gcc
LD = ld

#lib库的相对地址
LIB = -I lib/ -I lib/kernel/ -I lib/user/ -I kernel/ -I device/ -I thread/ -I userprog/

#定义flags参数
ASFLAGS = -f elf
CFLAGS = -Wall $(LIB) -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes -m32 -fno-stack-protector
LDFLAGS = -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map -m elf_i386

#目标文件连接的文件
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o \
	$(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/print.o \
	$(BUILD_DIR)/debug.o $(BUILD_DIR)/string.o $(BUILD_DIR)/bitmap.o \
	$(BUILD_DIR)/memory.o $(BUILD_DIR)/thread.o $(BUILD_DIR)/list.o \
	$(BUILD_DIR)/switch.o $(BUILD_DIR)/console.o $(BUILD_DIR)/sync.o \
	$(BUILD_DIR)/keyboard.o $(BUILD_DIR)/ioqueue.o $(BUILD_DIR)/tss.o \
	$(BUILD_DIR)/process.o $(BUILD_DIR)/syscall.o $(BUILD_DIR)/syscall-init.o \
	$(BUILD_DIR)/stdio.o


# 编译mbr和loader并写入磁盘
boot : $(BUILD_DIR)/mbr $(BUILD_DIR)/loader

$(BUILD_DIR)/mbr: boot/mbr.S
	@$(AS) -I boot/include/ -o $@ $<

$(BUILD_DIR)/loader: boot/loader.S
	@$(AS) -I boot/include/ -o $@ $<


############## c 代码编译 ############### 
$(BUILD_DIR)/main.o : kernel/main.c
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/init.o : kernel/init.c
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/interrupt.o : kernel/interrupt.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/timer.o : device/timer.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/console.o : device/console.c 
	$(CC) $(CFLAGS) $< -o $@ 
	
$(BUILD_DIR)/keyboard.o : device/keyboard.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/ioqueue.o : device/ioqueue.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/debug.o : kernel/debug.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/string.o : lib/string.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/bitmap.o : lib/kernel/bitmap.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/list.o : lib/kernel/list.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/memory.o : kernel/memory.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/thread.o : thread/thread.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/sync.o : thread/sync.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/tss.o : userprog/tss.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/process.o : userprog/process.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/syscall.o : lib/user/syscall.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/syscall-init.o : userprog/syscall-init.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/stdio.o : lib/stdio.c
	$(CC) $(CFLAGS) $< -o $@ 

############## 汇编代码编译 ############### 
$(BUILD_DIR)/kernel.o : kernel/kernel.S 
	@$(AS) $(ASFLAGS) $< -o $@ 

$(BUILD_DIR)/print.o : lib/kernel/print.S 
	@$(AS) $(ASFLAGS) $< -o $@ 

$(BUILD_DIR)/switch.o : thread/switch.S
	@$(AS) $(ASFLAGS) $< -o $@ 
	

############## 链接所有目标文件 ############# 
$(BUILD_DIR)/kernel.bin : $(OBJS) 
	$(LD) $(LDFLAGS) $^ -o $@ 

.PHONY : mk_dir hd clean all boot

#创建文件夹
mk_dir: 
	@if [ ! -d $(BUILD_DIR) ];then mkdir $(BUILD_DIR);fi 

#将文件写到磁盘里，> /dev/null 2>&1 将dd命令的默认输出定向到空洞文件，不在中断显示
hd: 
	@dd if=$(BUILD_DIR)/mbr of=$(HD60M_PATH) bs=512 count=1 conv=notrunc 
	@dd if=$(BUILD_DIR)/loader of=$(HD60M_PATH) bs=512 count=4 seek=2 conv=notrunc 
	@dd if=$(BUILD_DIR)/kernel.bin of=$(HD60M_PATH) bs=512 count=200 seek=9 conv=notrunc 

#清理文件
clean: 
	@cd $(BUILD_DIR) && rm -f ./* && echo "remove all file"


#编译kernel文件
build: $(BUILD_DIR)/kernel.bin 


#先创建build文件夹，下来编译mbr loader 下来编译kernel 最后加载到硬盘
all: mk_dir boot build hd 