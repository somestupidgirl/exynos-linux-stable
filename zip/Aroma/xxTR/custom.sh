### Custom Changes


cp -n /tmp/aroma/hotplug.prop /tmp/kernel/
cp -n /tmp/aroma/bigcpumax.prop /tmp/kernel/
cp -n /tmp/aroma/bigcpumin.prop /tmp/kernel/
cp -n /tmp/aroma/littlecpumax.prop /tmp/kernel/
cp -n /tmp/aroma/littlecpumin.prop /tmp/kernel/
HOTPLUG=$(cat /tmp/kernel/hotplug.prop | cut -d '=' -f2)
BIGCPUMAX=$(cat /tmp/kernel/bigcpumax.prop | cut -d '=' -f2)
BIGCPUMIN=$(cat /tmp/kernel/bigcpumin.prop | cut -d '=' -f2)
LITTLECPUMAX=$(cat /tmp/kernel/littlecpumax.prop | cut -d '=' -f2)
LITTLECPUMIN=$(cat /tmp/kernel/littlecpumin.prop | cut -d '=' -f2)

# begin ramdisk changes
if [ $BIGCPUMAX = 1 ]; then
  BIGCPUMAX_FREQ="2886000"
elif [ $BIGCPUMAX = 2 ]; then
  BIGCPUMAX_FREQ="2860000"
elif [ $BIGCPUMAX = 3 ]; then
  BIGCPUMAX_FREQ="2704000"
elif [ $BIGCPUMAX = 4 ]; then
  BIGCPUMAX_FREQ="2652000"
elif [ $BIGCPUMAX = 5 ]; then
  BIGCPUMAX_FREQ="2496000"
elif [ $BIGCPUMAX = 6 ]; then
  BIGCPUMAX_FREQ="2314000"
elif [ $BIGCPUMAX = 7 ]; then
  BIGCPUMAX_FREQ="2106000"
elif [ $BIGCPUMAX = 8 ]; then
  BIGCPUMAX_FREQ="2002000"
elif [ $BIGCPUMAX = 9 ]; then
  BIGCPUMAX_FREQ="1924000"
elif [ $BIGCPUMAX = 10 ]; then
  BIGCPUMAX_FREQ="1794000"
elif [ $BIGCPUMAX = 11 ]; then
  BIGCPUMAX_FREQ="1690000"
elif [ $BIGCPUMAX = 12 ]; then
  BIGCPUMAX_FREQ="1586000"
elif [ $BIGCPUMAX = 13 ]; then
  BIGCPUMAX_FREQ="1469000"
elif [ $BIGCPUMAX = 14 ]; then
  BIGCPUMAX_FREQ="1261000"
elif [ $BIGCPUMAX = 15 ]; then
  BIGCPUMAX_FREQ="1170000"
elif [ $BIGCPUMAX = 16 ]; then
  BIGCPUMAX_FREQ="1066000"
fi;

if [ $BIGCPUMIN = 1 ]; then
  BIGCPUMIN_FREQ="962000"
elif [ $BIGCPUMIN = 2 ]; then
  BIGCPUMIN_FREQ="858000"
elif [ $BIGCPUMIN = 3 ]; then
  BIGCPUMIN_FREQ="741000"
elif [ $BIGCPUMIN = 4 ]; then
  BIGCPUMIN_FREQ="650000"
else
  BIGCPUMIN_FREQ="598000"
fi;

if [ $LITTLECPUMAX = 1 ]; then
  LITTLECPUMAX_FREQ="2002000"
elif [ $LITTLECPUMAX = 2 ]; then
  LITTLECPUMAX_FREQ="1950000"
elif [ $LITTLECPUMAX = 3 ]; then
  LITTLECPUMAX_FREQ="1794000"
elif [ $LITTLECPUMAX = 4 ]; then
  LITTLECPUMAX_FREQ="1690000"
elif [ $LITTLECPUMAX = 5 ]; then
  LITTLECPUMAX_FREQ="1456000"
elif [ $LITTLECPUMAX = 6 ]; then
  LITTLECPUMAX_FREQ="1248000"
elif [ $LITTLECPUMAX = 7 ]; then
  LITTLECPUMAX_FREQ="1053000"
fi;

if [ $LITTLECPUMIN = 1 ]; then
  LITTLECPUMIN_FREQ="949000"
elif [ $LITTLECPUMIN = 2 ]; then
  LITTLECPUMIN_FREQ="832000"
elif [ $LITTLECPUMIN = 3 ]; then
  LITTLECPUMIN_FREQ="715000"
elif [ $LITTLECPUMIN = 4 ]; then
  LITTLECPUMIN_FREQ="598000"
elif [ $LITTLECPUMIN = 5 ]; then
  LITTLECPUMIN_FREQ="455000"
elif [ $LITTLECPUMIN = 6 ]; then
  LITTLECPUMIN_FREQ="299000"
else
  LITTLECPUMIN_FREQ="208000"
fi;

# modify init
echo "" >> $init_mod
echo "# Custom Freqs and Optimizations" >> $init_mod

if [ $HOTPLUG = 1 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 2704000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 2314000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 2314000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/highspeed_clock 598000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/unlock_freqs 1" >> $init_mod
  echo "    write /sys/power/unlock_freqs 1" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpufreq/policy0/schedutil/exp_util 1" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpufreq/policy4/schedutil/exp_util 1" >> $init_mod
  echo "    write /dev/stune/top-app/schedtune.boost 20" >> $init_mod
elif [ $HOTPLUG = 2 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 2652000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 2106000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 2106000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/highspeed_clock 598000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/unlock_freqs 1" >> $init_mod
  echo "    write /sys/power/unlock_freqs 1" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpufreq/policy4/schedutil/exp_util 1" >> $init_mod
elif [ $HOTPLUG = 3 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 2652000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 2002000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 2002000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/highspeed_clock 598000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/unlock_freqs 1" >> $init_mod
  echo "    write /sys/power/unlock_freqs 1" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpufreq/policy4/schedutil/exp_util 1" >> $init_mod
elif [ $HOTPLUG = 4 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 2496000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 1794000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 1794000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/highspeed_clock 598000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/unlock_freqs 1" >> $init_mod
  echo "    write /sys/power/unlock_freqs 1" >> $init_mod
elif [ $HOTPLUG = 6 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 2106000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 1690000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 1690000" >> $init_mod
  echo "    write /sys/module/workqueue/parameters/power_efficient Y" >> $init_mod
elif [ $HOTPLUG = 7 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 2002000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 1586000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 1586000" >> $init_mod
  echo "    write /sys/module/workqueue/parameters/power_efficient Y" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpuidle/use_deepest_state 1" >> $init_mod
elif [ $HOTPLUG = 8 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 1924000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 1469000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 1469000" >> $init_mod
  echo "    write /sys/module/workqueue/parameters/power_efficient Y" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpuidle/use_deepest_state 1" >> $init_mod
elif [ $HOTPLUG = 9 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq 1794000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq 1261000" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq 1261000" >> $init_mod
  echo "    write /sys/module/workqueue/parameters/power_efficient Y" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpuidle/use_deepest_state 1" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpufreq/policy4/schedutil/iowait_boost_enable 0" >> $init_mod
elif [ $HOTPLUG = 10 ]; then
  echo "    write /sys/power/cpuhotplug/governor/dual_freq $BIGCPUMAX_FREQ" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/triple_freq $BIGCPUMAX_FREQ" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/quad_freq $BIGCPUMAX_FREQ" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/highspeed_clock 598000" >> $init_mod
  echo "    write /sys/devices/platform/17500000.mali/unlock_freqs 1" >> $init_mod
  echo "    write /sys/power/unlock_freqs 1" >> $init_mod
  echo "    write /sys/power/cpuhotplug/governor/enabled 0" >> $init_mod
  echo "    write /sys/devices/system/cpu/cpufreq/policy4/schedutil/exp_util 1" >> $init_mod
fi;

echo "# End of script" >> $init_mod
# end ramdisk changes
