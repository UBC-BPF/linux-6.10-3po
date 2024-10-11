#!/bin/bash
#args:./benchmark.sh [results_dir] [RSS_in_pages]             [command to run in cgroup under memory pressure]

if [[ ! -d /mydata/traces ]]
then
	mkdir -p /mydata/traces
	sudo mkdir -p /data/
	sudo chown $USER -R /data
	ln -s /mydata/traces /data/traces
fi

export US_SIZES="10"
export RATIOS="5 10 15 20 25 30 35 40 45 50"
RUNTIME_RATIO=30

sudo rm -rf /data/traces/*
sudo ./trace_benchmark.sh python 107903 $RUNTIME_RATIO taskset -c 0 ~/miniconda3/bin/python python/mmult.py 4 4096 mat

sudo rm -rf /data/traces/*
sudo ./trace_benchmark.sh mmult_eigen 101394 $RUNTIME_RATIO taskset -c 0 ./cpp/mmult_eigen 4 4096 mat

sudo rm -rf /data/traces/*
mkdir /data/traces/mmult_eigen_par/
sudo GOMP_CPU_AFFINITY="0-1" OMP_SCHEDULE=static OMP_NUM_THREADS=2 ./trace_benchmark.sh mmult_eigen_par 101677 $RUNTIME_RATIO taskset -c 0,1 ./cpp/mmult_eigen_par 43 4096 mat
sudo mv tracing_results/mmult_eigen_par tracing_results/mmult_eigen_par_2

sudo rm -rf /data/traces/*
sudo GOMP_CPU_AFFINITY="0-2" OMP_SCHEDULE=static OMP_NUM_THREADS=3 ./trace_benchmark.sh mmult_eigen_par 101676 $RUNTIME_RATIO ./cpp/mmult_eigen_par 4 4096 mat
sudo mv tracing_results/mmult_eigen_par tracing_results/mmult_eigen_par_3

#sudo rm -rf /data/traces/*
#sudo GOMP_CPU_AFFINITY="0-3" OMP_SCHEDULE=static OMP_NUM_THREADS=4 ./trace_benchmark.sh mmult_eigen_par 101543 $RUNTIME_RATIO ./cpp/mmult_eigen_par 4 4096 mat
#sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_par_4

sudo rm -rf /data/traces/*
sudo ./trace_benchmark.sh mmult_eigen_vec 524718 $RUNTIME_RATIO taskset -c 0 ./cpp/mmult_eigen_vec 4 16384 vec

sudo rm -rf /data/traces/*
sudo ./trace_benchmark.sh mmult_eigen_dot 524652 $RUNTIME_RATIO taskset -c 0 ./cpp/mmult_eigen_dot 4 134217728 dot

sudo rm -rf /data/traces/*
sudo ./trace_benchmark.sh sort_merge 262921 $RUNTIME_RATIO taskset -c 0 ./cpp/sort_merge 42 268435456 bitonic_merge false

sudo rm -rf /data/traces/*
sudo ./trace_benchmark.sh sparse_eigen 296292 $RUNTIME_RATIO taskset -c 0 ./cpp/sparse_eigen 4 5500 false
