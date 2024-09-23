#ifndef EVICT_H
#define EVICT_H

#include <linux/workqueue.h>
#include <linux/memcontrol.h>
#include <linux/delay.h>
#include <linux/printk.h>
#include <linux/swap.h>

#include <linux/mm_inline.h> // for lru_to_page and other inline lru stuff

#include "common.h"
#include <linux/injections.h>

// #include <linux/frontswap.h>
#include <linux/pagemap.h>


void evict_init(void);
bool evict_initialized(void);
void evict_fini(void);
void evict_force_clean(void);

#endif /*EVICT_H*/
