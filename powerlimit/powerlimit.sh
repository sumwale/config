#ac_adapter=$(acpi -a | cut -d' ' -f3 | cut -d- -f1)
#if [ "$ac_adapter" = "on" ]; then
  #echo $ac_adapter
  #echo Applying...
  # MSR
  # PL1
  echo 26000000 > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_power_limit_uw # 26 watt
  echo 0 > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_0_time_window_us # inf
  # PL2
  echo 30000000 > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_power_limit_uw # 30 watt
  echo 28000000 > /sys/devices/virtual/powercap/intel-rapl/intel-rapl:0/constraint_1_time_window_us # 28 sec

  # MCHBAR
  # PL1
  echo 26000000 > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_power_limit_uw # 26 watt
  # ^ Only required change on a ASUS Zenbook UX430UNR
  echo 0 > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_0_time_window_us # inf
  # PL2
  echo 30000000 > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_power_limit_uw # 30 watt
  echo 28000000 > /sys/devices/virtual/powercap/intel-rapl-mmio/intel-rapl-mmio:0/constraint_1_time_window_us # 28 sec
#fi
