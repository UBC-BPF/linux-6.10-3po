import gc
gc.disable()
import sys
import resource

# put before importing np so it uses single thread
# https://stackoverflow.com/questions/30791550/limit-number-of-threads-in-numpy
import os
os.environ["MKL_NUM_THREADS"] = "1"
os.environ["NUMEXPR_NUM_THREADS"] = "1"
os.environ["OMP_NUM_THREADS"] = "1"

import numpy as np
from mem_pattern_trace import *

if len(sys.argv) < 3:
    print("Usage: python mmult.py SEED INPUT_SIZE")
    sys.exit(1)

SEED=int(sys.argv[1])
SIZE=int(sys.argv[2])

np.random.seed(SEED)

rng = np.random.default_rng(None if SEED == 0 else SEED)

syscall(mem_pattern_trace, TRACE_START | TRACE_AUTO)
coeff = rng.random(SIZE) + 1j
vals = np.fft.fft(coeff)
total = vals.sum()

syscall(mem_pattern_trace, TRACE_END)
rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
print("Result:", total)
print("Max RSS: %d kb or %d pages" % (rss, rss/4))
