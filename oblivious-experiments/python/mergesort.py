import gc
import resource
gc.disable()

# put before importing np so it uses single thread
# https://stackoverflow.com/questions/30791550/limit-number-of-threads-in-numpy
import os
os.environ["MKL_NUM_THREADS"] = "1"
os.environ["NUMEXPR_NUM_THREADS"] = "1"
os.environ["OMP_NUM_THREADS"] = "1"

import numpy as np
from mem_pattern_trace import *
SIZE=4096*4096

x = np.random.rand(1,1)
x = np.matmul(x,x)
np.random.seed(6)
syscall(mem_pattern_trace, TRACE_START | TRACE_AUTO)
a = np.random.rand(SIZE)
np.sort(a,kind="mergesort")
syscall(mem_pattern_trace, TRACE_END)
rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
print("Result: %d" % a.sum())
print("Max RSS: %d kb or %d pages" % (rss, rss/4))
