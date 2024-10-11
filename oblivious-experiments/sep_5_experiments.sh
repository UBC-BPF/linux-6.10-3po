#!/bin/bash
#args:./benchmark.sh [results_dir] [RSS_in_pages]             [command to run in cgroup under memory pressure]

if [[ ! -d /mydata/traces ]]
then
	mkdir -p /mydata/traces
	sudo mkdir -p /data/
	sudo chown $USER -R /data
	ln -s /mydata/traces /data/traces
fi

sudo rm -rf /data/traces/*
yes | sudo ./benchmark.sh python 107903 taskset -c 0 ~/miniconda3/bin/python python/mmult.py 4 4096 mat

sudo rm -rf /data/traces/*
yes | sudo PROG_NAME=python ./benchmark.sh pyfft 1055762 taskset -c 0 ~/miniconda3/bin/python python/fft.py 0 67108864

sudo rm -rf /data/traces/*
yes | sudo ./benchmark.sh mmult_eigen 101394 taskset -c 0 ./cpp/mmult_eigen 4 4096 mat

sudo rm -rf /data/traces/*
yes | sudo GOMP_CPU_AFFINITY="0-1" OMP_SCHEDULE=static OMP_NUM_THREADS=2 ./benchmark.sh mmult_eigen_par 101677 taskset -c 0,1 ./cpp/mmult_eigen_par 43 4096 mat
sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_par_2

sudo rm -rf /data/traces/*
yes | sudo GOMP_CPU_AFFINITY="0-2" OMP_SCHEDULE=static OMP_NUM_THREADS=3 ./benchmark.sh mmult_eigen_par 101676 ./cpp/mmult_eigen_par 4 4096 mat
sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_par_3

sudo rm -rf /data/traces/*
yes | sudo GOMP_CPU_AFFINITY="0-3" OMP_SCHEDULE=static OMP_NUM_THREADS=4 ./benchmark.sh mmult_eigen_par 101543 ./cpp/mmult_eigen_par 4 4096 mat
sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_par_4

sudo rm -rf /data/traces/*
yes | sudo ./benchmark.sh mmult_eigen_vec 524718 taskset -c 0 ./cpp/mmult_eigen_vec 4 16384 vec

sudo rm -rf /data/traces/*
yes | sudo ./benchmark.sh mmult_eigen_dot 524652 taskset -c 0 ./cpp/mmult_eigen_dot 4 134217728 dot

# sudo rm -rf /data/traces/*
# yes | sudo ./benchmark.sh sort_merge 262921 taskset -c 0 ./cpp/sort_merge 42 268435456 bitonic_merge false

sudo rm -rf /data/traces/*
yes | sudo ./benchmark.sh sparse_eigen 296292 taskset -c 0 ./cpp/sparse_eigen 4 5500 false
