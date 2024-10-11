#!/usr/bin/env bash
if [[ -z $1 ]]
then
	echo "Need argument"
	exit 1
fi
sudo rmmod leap_functionality
sudo insmod /mydata/Leap/example/leap_functionality.ko $1 $2
