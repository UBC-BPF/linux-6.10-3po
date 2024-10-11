#!/bin/bash
#args:./benchmark.sh [results_dir] [RSS_in_pages]             [command to run in cgroup under memory pressure]
CPU=1

sudo mkdir -p /data/traces
sudo chown $USER -R /data

pushd /mydata/oblivious/injector
make
./cli.sh tape_ops 1 us_size=60
popd

pushd /data/traces
mkdir -p mmult_eigen_vec
mkdir -p mmult_eigen
mkdir -p mmult_eigen_dot
mkdir -p sort
mkdir -p sort_merge
popd

MMULT_EIGEN_VEC_SIZE=$((4096*4))
MMULT_EIGEN_SIZE=4000
MMULT_EIGEN_DOT_SIZE=$((4096*4096*8))
SORT_SIZE=$((1<<25))
MERGE_SIZE=$((1<<28))

# RSS in *pages* (use /usr/bin/time -v and divide kb count by 4)
MMULT_EIGEN_VEC_MEM=524743
MMULT_EIGEN_MEM=125358
MMULT_EIGEN_DOT_MEM=524652
SORT_MEM=33530
MERGE_MEM=262906

taskset -c $CPU ./cpp/mmult_eigen_vec 4 $MMULT_EIGEN_VEC_SIZE vec
taskset -c $CPU ./cpp/mmult_eigen 4 $MMULT_EIGEN_SIZE mat
taskset -c $CPU ./cpp/mmult_eigen_dot 4 $MMULT_EIGEN_DOT_SIZE dot
taskset -c $CPU ./cpp/sort 42 $SORT_SIZE bitonic_sort false
taskset -c $CPU ./cpp/sort_merge 42 $MERGE_SIZE bitonic_merge false

POSTP=/mydata/oblivious/tracer/postprocess.py
python $POSTP /data/traces/mmult_eigen_vec/main.bin $MMULT_EIGEN_VEC_MEM 50
python $POSTP /data/traces/mmult_eigen/main.bin $MMULT_EIGEN_MEM 50
python $POSTP /data/traces/mmult_eigen_dot/main.bin $MMULT_EIGEN_DOT_MEM 50
python $POSTP /data/traces/sort/main.bin $SORT_MEM 50
python $POSTP /data/traces/sort_merge/main.bin $MERGE_MEM 50

sudo ./benchmark.sh mmult_eigen_vec $MMULT_EIGEN_VEC_MEM 		             taskset -c $CPU ./cpp/mmult_eigen_vec 4 $MMULT_EIGEN_VEC_SIZE vec
###########sudo ./benchmark.sh native_sort  $((1500+ 8*(1<<25)/4096))  taskset -c $CPU /home/narekg/Prefetching/sorting/sort $((1<<25)) 42  native_sort false
sudo ./benchmark.sh mmult_eigen $MMULT_EIGEN_MEM 		             taskset -c $CPU ./cpp/mmult_eigen 4 $MMULT_EIGEN_SIZE mat
sudo ./benchmark.sh mmult_eigen_dot $MMULT_EIGEN_DOT_MEM 		             taskset -c $CPU ./cpp/mmult_eigen_dot 4 $MMULT_EIGEN_DOT_SIZE dot
sudo ./benchmark.sh sort  33529  taskset -c $CPU ./cpp/sort 42 $SORT_SIZE bitonic_sort false
sudo ./benchmark.sh sort_merge 262000  taskset -c $CPU ./cpp/sort_merge 42 $MERGE_SIZE bitonic_merge false


#sudo ./benchmark.sh mmap_random_rw 400000 		     taskset -c $CPU ./cpp/mmap_random_rw 4 400000 1200000 w
#sudo ./benchmark.sh kissfft     291064  taskset -c $CPU /home/narekg/oblivious/experiments/cpp/kissfft/build/test/bm_kiss-int16_t -x 1 -n 100,100,100,100
#sudo ./benchmark.sh kmeans 142000 			    taskset -c $CPU /home/narekg/miniconda2/bin/python ./python/kmeans.py


