#!/bin/sh

. /usr/local/etc/powerlimit.conf

#ac_adapter=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
#if [ "$ac_adapter" = "on" ]; then
  #echo $ac_adapter
  #echo Applying...
  # MSR
  # PL1
  echo $LIMIT_0_MICROWATT > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw
  if [ -n "$TIME_0_MICROS" ]; then
    echo $TIME_0_MICROS > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us
  fi
  # PL2
  echo $LIMIT_1_MICROWATT > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw
  echo $TIME_1_MICROS > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_time_window_us

  if [ -e /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0 ]; then
    # MCHBAR
    # PL1
    echo $LIMIT_0_MICROWATT > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw
    # ^ Only required change on a ASUS Zenbook UX430UNR
    if [ -n "$TIME_0_MICROS" ]; then
      echo $TIME_0_MICROS > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_time_window_us
    fi
    # PL2
    echo $LIMIT_1_MICROWATT > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_power_limit_uw
    echo $TIME_1_MICROS > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_time_window_us
  fi
#fi
