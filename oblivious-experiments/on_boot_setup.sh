#!/bin/bash
# N.B. must be run after remote memory daemon(rmserver) is running
# N.B.2 update syncswap/driver/load.sh accordingly before running

OBL_DIR=/mydata/oblivious
### aslr & thp
echo never | sudo tee  /sys/kernel/mm/transparent_hugepage/enabled
echo 0 | sudo tee /proc/sys/kernel/randomize_va_space
echo "aslr : $(cat /proc/sys/kernel/randomize_va_space)"
echo "transparent huge pages: $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
# to enable `
# echo 2 | sudo tee /proc/sys/kernel/randomize_va_space

### cgroup fs
mount -t cgroup2 nodev /cgroup2
sh -c "echo '+memory' > /cgroup2/cgroup.subtree_control"

# configure host for experiments
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
# todo:: cloudlab seems to not use intel_pstate..
# docs for later exploration:
# 1) https://www.kernel.org/doc/html/v4.12/admin-guide/pm/intel_pstate.html
# 2) https://wiki.archlinux.org/title/CPU_frequency_scaling
# echo 1 | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo

### load fastswap
sudo swapoff -a
sudo swapon /mydata/swapfile
(cd $OBL_DIR/syncswap/drivers && ./load.sh )

