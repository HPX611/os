#一些编译工具参数
BUILD_DIR=./build
ENTRY_POINT = 0xc0001500
AS = nasm
CC = gcc
LD = ld
LIB = -I lib/ -I lib/kernel/ -I lib/user/ -I kernel/ -I device/

#定义flags参数
ASFLAGS = -f elf
CFLAGS = -Wall $(LIB) -c -fno-builtin -W -Wstrict-prototypes -Wmissing-prototypes -m32 -fno-stack-protector
LDFLAGS = -Ttext $(ENTRY_POINT) -e main -Map $(BUILD_DIR)/kernel.map -m elf_i386

#目标文件连接的文件
OBJS = $(BUILD_DIR)/main.o $(BUILD_DIR)/init.o $(BUILD_DIR)/interrupt.o \
	$(BUILD_DIR)/timer.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/print.o \
	$(BUILD_DIR)/debug.o

############## c 代码编译 ############### 
$(BUILD_DIR)/main.o : kernel/main.c
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/init.o : kernel/init.c
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/interrupt.o : kernel/interrupt.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/timer.o : device/timer.c 
	$(CC) $(CFLAGS) $< -o $@ 

$(BUILD_DIR)/debug.o : kernel/debug.c 
	$(CC) $(CFLAGS) $< -o $@ 

############## 汇编代码编译 ############### 
$(BUILD_DIR)/kernel.o : kernel/kernel.S 
	$(AS) $(ASFLAGS) $< -o $@ 

$(BUILD_DIR)/print.o : lib/kernel/print.S 
	$(AS) $(ASFLAGS) $< -o $@ 

############## 链接所有目标文件 ############# 
$(BUILD_DIR)/kernel.bin : $(OBJS) 
	$(LD) $(LDFLAGS) $^ -o $@ 

.PHONY : mk_dir hd clean all 

mk_dir: 
	if [ ! -d $(BUILD_DIR) ];then mkdir $(BUILD_DIR);fi 

hd: 
	dd if=$(BUILD_DIR)/kernel.bin \
	of=/home/cdh/os/bochs/hd60M.img \
	bs=512 count=200 seek=9 conv=notrunc 

clean: 
	@cd $(BUILD_DIR) && rm -f ./* && echo "remove all file"

build: $(BUILD_DIR)/kernel.bin 

all: mk_dir build hd 