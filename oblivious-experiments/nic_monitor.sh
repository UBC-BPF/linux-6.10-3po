#!/bin/bash
#NIC_DEVICE="mlx5_3"
NIC_DEVICE="mlx5_1"
#NIC_DEVICE="mlx4_0"

t0=$(($(date +%s%N)/1000000))
recv0=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_rcv_data");
xmit0=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_xmit_data");
echo "TIME,RECV,XMIT"
while true; do
	recv=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_rcv_data");
	recv=$((($recv-$recv0) * 4))
	xmit=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_xmit_data");
	xmit=$((($xmit-$xmit0) * 4))
	t=$(($(date +%s%N)/1000000))
	t=$(($t-$t0))
	echo $t,$recv,$xmit
	sleep 0.1; done
