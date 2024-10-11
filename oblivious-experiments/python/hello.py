import numpy as np

import sys
import os
import resource
c = np.random.rand(4096)
a = [0] * 4000000
b = [0] * 4000000
c = [ai + bi for (ai,bi) in zip(a,b)]
#syscall(mem_pattern_trace, TRACE_END)
rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
#print("Result: %d" % c.sum())
print("Max RSS: %d kb or %d pages" % (rss, rss/4))
#sys.exit(0)
print("exited")
