#!/bin/bash
#args:./benchmark.sh [results_dir] [RSS_in_pages]             [command to run in cgroup under memory pressure]

sudo mkdir -p /data/traces
sudo chown $USER -R /data

#sudo GOMP_CPU_AFFINITY="0-6" OMP_SCHEDULE=static OMP_NUM_THREADS=7 ./benchmark.sh torch_par $((148000)) taskset -c 0,1,2,3,4,5,6 ./cpp/torch_example/build/infer20
#sudo GOMP_CPU_AFFINITY="0-3" OMP_SCHEDULE=static OMP_NUM_THREADS=4 ./benchmark.sh torch_par4 $((148000)) taskset -c 0,1,2,3 ./cpp/torch_example/build/infer20
#sudo GOMP_CPU_AFFINITY="0" OMP_SCHEDULE=static OMP_NUM_THREADS=1 ./benchmark.sh torch $((148000)) taskset -c 0 ./cpp/torch_example/build/infer
for cnt in {8..19}
do
	ps ax | grep nic_monitor| awk '{print $1}'| xargs sudo kill -9
	sudo rm -r /data/traces/mmult_eigen_par/*
	yes | sudo GOMP_CPU_AFFINITY="8-$cnt" OMP_SCHEDULE=static OMP_NUM_THREADS=$(($cnt-7)) ./benchmark.sh mmult_eigen_par 134000 ./cpp/mmult_eigen_par 43 4096 mat
	sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_par_$(($cnt-7))

	sudo rm -r /data/traces/mmult_eigen_par/*
	yes | sudo GOMP_CPU_AFFINITY="8-$cnt" OMP_SCHEDULE=static OMP_NUM_THREADS=$(($cnt-7)) ./benchmark.sh mmult_eigen_par $((530000)) ./cpp/mmult_eigen_par 43 $((4096*4)) vec
	sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_vec_par_$(($cnt-7))

	sudo rm -r /data/traces/mmult_eigen_par/*
	yes | sudo GOMP_CPU_AFFINITY="8-$cnt" OMP_SCHEDULE=static OMP_NUM_THREADS=$(($cnt-7)) ./benchmark.sh mmult_eigen_par $((530000)) ./cpp/mmult_eigen_par 43 $((4096*4096*8)) dot
	sudo mv experiment_results/mmult_eigen_par experiment_results/mmult_eigen_dot_par_$(($cnt-7))
done
#sudo ./benchmark.sh bitonic_merge $((1500+ 8*(1<<28)/4096))  taskset -c 0 /home/narekg/Prefetching/sorting/sort $((1<<28)) 42  bitonic_merge false
#sudo ./benchmark.sh bitonic_sort  $((1500+ 8*(1<<25)/4096))  taskset -c 0 /home/narekg/Prefetching/sorting/sort $((1<<25)) 42  bitonic_sort false
#sudo ./benchmark.sh native_sort  $((1500+ 8*(1<<25)/4096))  taskset -c 0 /home/narekg/Prefetching/sorting/sort $((1<<25)) 42  native_sort false
#sudo KMP_AFFINITY=nowarnings,compact,1,0,granularity=fine MKL_NUM_THREADS=4 OMP_NUM_THREADS=4 MKL_DOMAIN_NUM_THREADS=4 ./benchmark.sh linpack 406000 taskset -c 0,1,2,3 /home/narekg/oblivious/experiments/cpp/cfm/linpack/xlinpack_xeon64 /home/narekg/oblivious/experiments/cpp/cfm/linpack/lininput_xeon64



#sudo ./benchmark.sh mmap_random_rw 400000 		     taskset -c 0 ./cpp/mmap_random_rw 4 400000 1200000 w
#sudo ./benchmark.sh kissfft     291064  taskset -c 0 /home/narekg/oblivious/experiments/cpp/kissfft/build/test/bm_kiss-int16_t -x 1 -n 100,100,100,100
#sudo ./benchmark.sh kmeans 142000 			    taskset -c 0 /home/narekg/miniconda2/bin/python ./python/kmeans.py


