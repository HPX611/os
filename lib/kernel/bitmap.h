#ifndef __LIB_KERNEL_BITMAP_H 
#define __LIB_KERNEL_BITMAP_H 
#include "global.h" 
#define BITMAP_MASK 1 

struct bitmap { 
    uint32_t btmp_bytes_len; 
    /* 在遍历位图时，整体上以字节为单位，细节上是以位为单位， 所以此处位图的指针必须是单字节 */ 
    //指针 bits 来记录位图的地址，真正的位图由上一级模块提供，并由上一级模块把位图的地址赋值给 bits
    uint8_t* bits; 
}; 

void bitmap_init(struct bitmap* btmp); 
bool bitmap_scan_test(struct bitmap* btmp, uint32_t bit_idx); 
int bitmap_scan(struct bitmap* btmp, uint32_t cnt); 
void bitmap_set(struct bitmap* btmp, uint32_t bit_idx, int8_t value); 
#endif 