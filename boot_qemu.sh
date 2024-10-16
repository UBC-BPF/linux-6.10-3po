#!/bin/bash

qemu-system-x86_64 \
    -enable-kvm \
    -m 819200 \
    -net user,hostfwd=tcp::10023-:22,hostfwd=tcp::8000-:8000 \
    -net nic \
    -nic user\
    -hda ../ubuntu-24.04.qcow2 \
    -smp 64 \
    -cpu max \
    -virtfs local,path=/home/tanyapsd/workspace/linux-6.10-3po,mount_tag=share,security_model=mapped,id=share \
    -serial mon:stdio -nographic -display curses
