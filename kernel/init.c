#include "init.h" 


/*负责初始化所有模块 */ 
void init_all(void) { 
    put_str("init_all\n"); 
    idt_init();                 //初始化中断 
    timer_init();               // 初始化 PIT 
    mem_init();                // 初始化内存管理
} 