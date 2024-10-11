from ai_benchmark import AIBenchmark
from mem_pattern_trace import *


syscall(mem_pattern_trace, TRACE_START | TRACE_AUTO)
benchmark = AIBenchmark(use_CPU=True)
results = benchmark.run_inference()


syscall(mem_pattern_trace, TRACE_END)
