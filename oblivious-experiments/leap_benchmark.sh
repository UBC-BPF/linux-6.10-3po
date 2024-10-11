#!/usr/bin/env bash


kbytes_to_pages() {
    expr \( $1 + 3 \) / 4
}

NAME=$1
PROGRAM_NAME=$2
INVOCATION=${@:3}

CLI=~/oblivious-experiments/leap_cli.sh
CGROUP_NAME=leap_bench
NIC_DEVICE=mlx4_0

if [[ -z $NAME ]] || [[ -z $INVOCATION ]]
then
	echo "Bad arguments"
	exit 1
fi

sudo cgcreate -g memory:$CGROUP_NAME

OUTPUT_DIR=leap_bench_output/$NAME
mkdir -p $OUTPUT_DIR

echo $INVOCATION > $OUTPUT_DIR/invocation

if [[ -z $MEM_SIZE_PAGES ]]
then
	echo "running the program once to get its memory size"
	/usr/bin/time -v $INVOCATION 2> $OUTPUT_DIR/unrestricted.time
	MEM_SIZE_KBYTES=$(cat $OUTPUT_DIR/unrestricted.time | grep "Maximum resident set size (kbytes)" | cut -d " " -f 6)
	MEM_SIZE_PAGES=$(kbytes_to_pages $MEM_SIZE_KBYTES)
else
	echo "using explicitly passed memory size"
	MEM_SIZE_KBYTES=$((4 * $MEM_SIZE_PAGES))
fi
echo "Memory size is" $MEM_SIZE_KBYTES "kbytes (" $MEM_SIZE_PAGES " pages)"

function run_experiment() {
	local RATIO=$1
	local MODE=$2 # either "readahead" or "prefetch"
	local SETUP_NAME=$3

	# Set mode to "readahead" or "prefetch" as appropriate
	$CLI cmd=$MODE
	sleep 1

	# I've commented this out and replaced it with updated logic (see the comment below)
	#$CLI cmd="init" process_name=$PROGRAM_NAME & # The Leap kernel module polls for the process every second
	#sleep 0.75

	# The Leap authors confirmed to me over email that, in their current implementation, the
	# particular process it's attached to doesn't matter. All that matters is that the PID is not
	# 0. So we attach to a "sleep" process, to enable Leap; the implementation will also use
	# Leap for the actual program we're running.
	sleep 3 &
	$CLI cmd="init" process_name="sleep"
	wait


	MAJFLT=$(cat "/sys/fs/cgroup/memory/$CGROUP_NAME/memory.stat" | grep "total_pgmajfault" | cut -d ' ' -f 2)
	FLT=$(cat "/sys/fs/cgroup/memory/$CGROUP_NAME/memory.stat" | grep "total_pgfault" | cut -d ' ' -f 2)

	# Reset performance counters; they stop working once they reach 0xFFFFFFFF.
	sudo perfquery -R -a
	PAGES_SWAPPED_IN=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_rcv_data")
	PAGES_SWAPPED_OUT=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_xmit_data")

	local RUN_STATS=$(sudo cgexec -g memory:leap_bench /usr/bin/time -f "%U,%S,%E,%F,%R" $INVOCATION 3>&2 2>&1 1>&3)
	PAGES_SWAPPED_IN_FINAL=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_rcv_data")
	PAGES_SWAPPED_OUT_FINAL=$(cat "/sys/class/infiniband/$NIC_DEVICE/ports/1/counters/port_xmit_data")
	PAGES_SWAPPED_IN=$(((${PAGES_SWAPPED_IN_FINAL}-${PAGES_SWAPPED_IN}) * 4 / 4096))
	PAGES_SWAPPED_OUT=$(((${PAGES_SWAPPED_OUT_FINAL}-${PAGES_SWAPPED_OUT}) * 4 / 4096))
	if [[ $PAGES_SWAPPED_IN_FINAL = $((0xFFFFFFFF)) ]]
	then
		PAGES_SWAPPED_IN=-1
	fi
	if [[ $PAGES_SWAPPED_OUT_FINAL = $((0xFFFFFFFF)) ]]
	then
		PAGES_SWAPPED_OUT=-1
	fi

	MAJFLT=$(expr $(cat "/sys/fs/cgroup/memory/$CGROUP_NAME/memory.stat" | grep "total_pgmajfault" | cut -d ' ' -f 2) - $MAJFLT)
        FLT=$(expr $(cat "/sys/fs/cgroup/memory/$CGROUP_NAME/memory.stat" | grep "total_pgfault" | cut -d ' ' -f 2) - $FLT)

	echo $RATIO,$RUN_STATS,$PAGES_SWAPPED_OUT,$PAGES_SWAPPED_IN >> $OUTPUT_DIR/${SETUP_NAME}.stats
	echo $RATIO,$FLT,$MAJFLT >> $OUTPUT_DIR/${SETUP_NAME}.cgroup
}

STATS_HEADER="RATIO,USER,SYSTEM,WALLCLOCK,MAJOR_FAULTS,MINOR_FAULTS,PAGES_EVICTED,PAGES_SWAPPED_IN"
echo $STATS_HEADER > $OUTPUT_DIR/linux.stats
echo $STATS_HEADER > $OUTPUT_DIR/leap.stats

CGROUP_HEADER="RATIO,NUM_FAULTS,NUM_MAJOR_FAULTS"
echo $CGROUP_HEADER > $OUTPUT_DIR/linux.cgroup
echo $CGROUP_HEADER > $OUTPUT_DIR/leap.cgroup

for MEM_RATIO in 100 90 80 70 60 50 40 30 20 10 5
do
	EXP_LOCAL_MEM_KBYTES=$(expr $MEM_SIZE_KBYTES \* $MEM_RATIO / 100)
	EXP_LOCAL_MEM_PAGES=$(kbytes_to_pages $EXP_LOCAL_MEM_KBYTES)
	echo "Run at memory ratio" $MEM_RATIO "(" $EXP_LOCAL_MEM_KBYTES "kbytes," $EXP_LOCAL_MEM_PAGES "pages)"

	echo ${EXP_LOCAL_MEM_KBYTES}K | sudo tee /sys/fs/cgroup/memory/${CGROUP_NAME}/memory.limit_in_bytes

	# Enable Leap's remote I/O datapath (required whether we use Leap's prefetching or not)
	sleep 3 &
	$CLI cmd="init" process_name="sleep"
	wait

	run_experiment $MEM_RATIO "readahead" "linux"
	run_experiment $MEM_RATIO "prefetch" "leap"
done
