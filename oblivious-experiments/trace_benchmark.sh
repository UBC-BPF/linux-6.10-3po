#!/usr/bin/env bash

OBL_DIR="/mydata/oblivious"
PYTHON="$HOME/miniconda3/bin/python"

EXPERIMENT_NAME=$1
MEMORY_SIZE_PAGES=$2
RUNTIME_RATIO=$3
INVOCATION=${@:4}

PROGRAM_NAME=${PROG_NAME:-$EXPERIMENT_NAME}

# I copied this from benchmark.sh
POSTPROCESS_FETCH_BATCH_SIZE=50

if [[ -z $US_SIZES ]]
then
	echo "US_SIZES must be set"
	exit 1
fi

if [[ -z $RATIOS ]]
then
	echo "RATIOS must be set"
	exit 1
fi

trace() {
	sudo rm -rf /data/traces/*

	pushd $OBL_DIR/injector
	./cli.sh tape_ops 1
	./cli.sh us_size $1
	popd
	mkdir -p /data/traces/$PROGRAM_NAME

	# the pipe manipulation at the end of the line below swaps stdout and stderr so RUN_TIME variable
	# will capture %U %S %E" but the program output wil be printed in terminal (as stderr though!!)
	# ASSUMES THE PROGRAM RUN DOES NOT PRODUCE ANY STDERR
	RUN_TIME=$((GOMP_CPU_AFFINITY="1" OMP_SCHEDULE=static /usr/bin/time -f "%U,%S,%E,%F,%R" taskset -c 1 $INVOCATION) 3>&2 2>&1 1>&3 )
	TRACE_SIZE=$(du -b -c /data/traces/$PROGRAM_NAME/$ratio/*.bin.* | tail -n 1 | cut -f 1)
}

postprocess() {
	# The progress bar writes to standard error, so we can't use the redirection trick from above
	echo "Postprocessing with ratio $1"
	/usr/bin/time -o temporary_file -a -f "%U,%S,%E,%F,%R" $PYTHON $OBL_DIR/tracer/postprocess.py /data/traces/$PROGRAM_NAME/main.bin $MEMORY_SIZE_PAGES $POSTPROCESS_FETCH_BATCH_SIZE $1
	RUN_TIME=$(cat temporary_file)
	TAPE_SIZE=$(du -b -c /data/traces/$PROGRAM_NAME/$1/*.tape.* | tail -n 1 | cut -f 1)
	rm temporary_file
}

OUTPUT_DIR=tracing_results/$EXPERIMENT_NAME
mkdir -p $OUTPUT_DIR
TRACE_HEADER="US_SIZE,USER,SYSTEM,WALLCLOCK,MAJOR_FAULTS,MINOR_FAULTS,TRACE_SIZE"
TRACE_STATS_FILE=$OUTPUT_DIR/trace.stats
echo $TRACE_HEADER > $TRACE_STATS_FILE

POSTP_HEADER="US_SIZE,RATIO,USER,SYSTEM,WALLCLOCK,MAJOR_FAULTS,MINOR_FAULTS,TAPE_SIZE"
POSTP_STATS_FILE=$OUTPUT_DIR/postp.stats
echo $POSTP_HEADER > $POSTP_STATS_FILE

for US_SIZE in $US_SIZES
do
	trace $US_SIZE
	TRACE_STATS=$RUN_TIME
	echo $US_SIZE,$TRACE_STATS,$TRACE_SIZE >> $TRACE_STATS_FILE

	for RATIO in $RATIOS
	do
		postprocess $RATIO
		POSTP_STATS=$RUN_TIME
		echo $US_SIZE,$RATIO,$POSTP_STATS,$TAPE_SIZE >> $POSTP_STATS_FILE

		if [[ $RATIO != $RUNTIME_RATIO ]]
		then
			pushd /data/traces/$PROGRAM_NAME
			sudo rm -rf $RUNTIME_RATIO
			sudo mv $RATIO $RUNTIME_RATIO
			popd
		fi

		echo y | RATIOS=$RUNTIME_RATIO US=$US_SIZE ./benchmark.sh $EXPERIMENT_NAME $2 $INVOCATION
		sudo mv experiment_results/$EXPERIMENT_NAME $OUTPUT_DIR/${US_SIZE}-$RATIO
	done
done
