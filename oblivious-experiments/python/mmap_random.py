import resource
from random import randint,seed
from mem_pattern_trace import *

seed(42)

syscall(mem_pattern_trace, TRACE_START | TRACE_AUTO)
NUM_PAGES=400000
NUM_OPS= 800000
arr = [0] * (4096//8 * NUM_PAGES)
for i in range(NUM_OPS):
    arr[randint(0,len(arr))] = 0xff

syscall(mem_pattern_trace, TRACE_END)
rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
print("Max RSS: %d kb or %d pages" % (rss, rss/4))
