# oblivious-experiments


| File | Description |
| ---- | ----------- |
| [CLoudlab deployment](deploy_oblivlious_on_cloudlab.sh)| Long list of commands that turns a fresh cloudlab instance into one ready for our evaluation experiments. Note that the script requires at least 2 restarts between stages and relevant sections must be run manually (just running the script once will not do it, todo:: automate later). Most steps in the script are optional for remote memory server but I have usually done them to just make the environment symetric|
| [benchmark.sh](benchmark.sh)|Main benchmarking script used to generate raw data (spilled to disc as csvs in experiment_results). Usage is quite simple but below there also are some exaples|
| [analysis/experiment_helpers.py](analysis/experiment_helpers.py)| Helper functions that turn raw ftrace/time/cgroup/nic and other collected data into metrics that we care about. __Would be great to have the logic reviewed by someone else__. This has been a source of bugs in the past|
| [analysis/oblivious.ipynb](analysis/oblivious.ipynb)| Data exploration notebook. Uses the API from the helpers above|
| [cpp workloads](cpp/)| |
| [python workloads](python/)| |


### Usage exaples of benchmark.sh
```
#Usage: sudo ./benchmark.sh experiment_name num_pages program_invocation
```
Exaples:
```
sudo ./benchmark.sh mmult_eigen_dot 528000 taskset -c $CPU ./cpp/mmult_eigen_dot 4 $((4096*4096*8)) dot
sudo ./benchmark.sh sort  33529  taskset -c $CPU ./cpp/sort 42 $((1<<25)) bitonic_sort false
RATIOS=20 sudo ./benchmark.sh sort_merge 262000  taskset -c $CPU ./cpp/sort_merge 42 $((1<<28)) bitonic_merge false
```
