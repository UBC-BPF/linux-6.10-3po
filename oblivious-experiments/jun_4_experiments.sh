#!/bin/bash
#args:./benchmark.sh [results_dir] [RSS_in_pages]             [command to run in cgroup under memory pressure]
CPU=1

#taskset -c $CPU ./cpp/mmult_eigen_vec 4 $((4096*4)) vec
#taskset -c $CPU ./cpp/mmult_eigen 4 4096 mat
#taskset -c $CPU ./cpp/mmult_eigen_dot 4 $((4096*4096*8)) dot
#taskset -c $CPU ./cpp/sort 42 $((1<<25)) bitonic_sort false
#taskset -c $CPU ./cpp/sort_merge 42 $((1<<28)) bitonic_merge false

#POSTP=/mydata/oblivious/tracer/postprocess.py
#python $POSTP /data/traces/mmult_eigen_vec/main.bin 528000 50
#python $POSTP /data/traces/mmult_eigen/main.bin 134000 50
#python $POSTP /data/traces/mmult_eigen_dot/main.bin 528000 50
#python $POSTP /data/traces/sort/main.bin 134000 50
#python $POSTP /data/traces/sort_merge/main.bin 1051644 50


########## sudo ./benchmark.sh mmult_eigen_vec $((528000)) 		             taskset -c $CPU ./cpp/mmult_eigen_vec 4 $((4096*4)) vec
#sudo ./benchmark.sh native_sort  $((1500+ 8*(1<<25)/4096))  taskset -c $CPU /home/narekg/Prefetching/sorting/sort $((1<<25)) 42  native_sort false
########## sudo ./benchmark.sh mmult_eigen 134000 		             taskset -c $CPU ./cpp/mmult_eigen 4 4096 mat
sudo ./benchmark.sh mmult_eigen_dot 528000 		             taskset -c $CPU ./cpp/mmult_eigen_dot 4 $((4096*4096*8)) dot
sudo ./benchmark.sh sort  33529  taskset -c $CPU ./cpp/sort 42 $((1<<25)) bitonic_sort false
sudo ./benchmark.sh sort_merge 262000  taskset -c $CPU ./cpp/sort_merge 42 $((1<<28)) bitonic_merge false


#sudo ./benchmark.sh mmap_random_rw 400000 		     taskset -c $CPU ./cpp/mmap_random_rw 4 400000 1200000 w
#sudo ./benchmark.sh kissfft     291064  taskset -c $CPU /home/narekg/oblivious/experiments/cpp/kissfft/build/test/bm_kiss-int16_t -x 1 -n 100,100,100,100
#sudo ./benchmark.sh kmeans 142000 			    taskset -c $CPU /home/narekg/miniconda2/bin/python ./python/kmeans.py


