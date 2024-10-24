#ifndef __KERNEL_INIT_H
#define __KERNEL_INIT_H

#include "print.h" 
#include "interrupt.h" 
#include "timer.h"
#include "memory.h"
#include "thread.h"
#include "debug.h"
#include "list.h"

void init_all(void);

#endif
