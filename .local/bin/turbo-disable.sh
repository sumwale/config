#!/bin/sh

arg=$1
if [ -z "$arg" ]; then
  arg=1
fi

if [ $arg -eq 0 ]; then
  sudo cpupower frequency-set -u 5000000000
fi

echo $arg | sudo tee /sys/devices/system/cpu/intel_pstate/no_turbo
