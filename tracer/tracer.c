#include "tracer.h"
#include <linux/printk.h>
#include<linux/injections.h>
#include <linux/syscalls.h>

SYSCALL_DEFINE1(mem_pattern_trace, int, flags)
{
	printk (KERN_INFO "in mem pattern trace start %d", flags);
	(*pointers[3])(flags);
	return 0;
}
