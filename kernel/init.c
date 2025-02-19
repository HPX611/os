#include "init.h" 


/*负责初始化所有模块 */ 
void init_all() { 
    put_str("init_all\n"); 
    idt_init(); // 初始化中断 
    mem_init(); // 初始化内存管理系统 
    thread_init(); // 初始化线程相关结构 
    timer_init(); // 初始化 PIT 
    console_init(); //控制台初始化最好放在开中断之前 
    keyboard_init(); // 键盘初始化
    tss_init(); //初始化tss段
    syscall_init();
    ide_init();	     // 初始化硬盘
} 