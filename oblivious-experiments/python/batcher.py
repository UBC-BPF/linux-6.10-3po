import random
import gc
import resource
gc.disable()

from mem_pattern_trace import *
blah = random.randint(4,5)
def compare_swap(a, i, j, d):
    if (d == 1 and a[i] > a[j]) or (d == 0 and a[i] < a[j]):
        a[i], a[j] = a[j], a[i]


def merge(a, l, cnt, d):
    if cnt > 1:
        k = int(cnt / 2)
        for i in range(l, l + k):
            compare_swap(a, i, i + k, d)
        merge(a, l, k, d)
        merge(a, l + k, k, d)

def bitonic_sort(a, l, cnt, d):
    if cnt > 1:
        k = int(cnt / 2)
        bitonic_sort(a, l, k, 1)
        bitonic_sort(a, l + k, k, 0)
        merge(a, l, cnt, d)


def sort(a, N, u):
    bitonic_sort(a, 0, N, u)

syscall(mem_pattern_trace, TRACE_START | TRACE_AUTO)
n=1<<18
a = [random.randint(0, 1000000000) for i in range(n)]

u = 1
sort(a, n, u)
syscall(mem_pattern_trace, TRACE_END)
if (a == sorted(a)):
    print ("list is sorted")
else:
    print ("list is not sorted")


rss = resource.getrusage(resource.RUSAGE_SELF).ru_maxrss
#print("Result: %d" % a.sum())
print("Max RSS: %d kb or %d pages" % (rss, rss/4))
