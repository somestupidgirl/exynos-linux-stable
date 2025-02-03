### Finish Setup

# copy init
mount /odm;
mount -o remount,rw /odm;
mkdir -p /odm/etc
mkdir -p /odm/etc/init

# begin kernel changes
device_name=$(file_getprop /default.prop ro.product.device);
cp -n /tmp/aroma/rom.prop /tmp/kernel/
cp -n /tmp/aroma/dts.prop /tmp/kernel/
rom_number=$(cat /tmp/kernel/rom.prop | cut -d '=' -f2)
dts_number=$(cat /tmp/kernel/dts.prop | cut -d '=' -f2)
ui_print " ";
ROM_UIPRINT="Using"
if [ $rom_number = 2 ]; then
  ROM_UIPRINT="${ROM_UIPRINT} Stock Rom (Android 10)";
  ROM_NAME="Kernel-stock"
elif [ $rom_number = 3 ]; then
  ROM_UIPRINT="${ROM_UIPRINT} Aosp Base";
  ROM_NAME="Kernel-aosp"
else
  ROM_UIPRINT="${ROM_UIPRINT} Latest Base";
  ROM_NAME="Kernel"
fi;
if [ $BOOT = 2 ] || [ $BOOT = 3 ]; then
  ROM_UIPRINT="${ROM_UIPRINT} with KernelSU Support";
  ROM_NAME="$ROM_NAME-ksu"
fi;
ui_print "${ROM_UIPRINT}";
ROM_UIPRINT="";
ui_print "";
if [ $dts_number = 2 ]; then
  ui_print "Using EROFS root fstab";
  DTB_NAME="Dtb-erofs"
else
  ui_print "Using EXT4 root fstab";
  DTB_NAME="Dtb"
fi;
tar xf $home/Kernel.tar $ROM_NAME/$device_name/zImage
tar xf $home/Kernel.tar $DTB_NAME/$device_name/dtb.img
rm $home/Kernel.tar

mv -f $ROM_NAME/$device_name/zImage $home/Image;
mv -f $DTB_NAME/$device_name/dtb.img $split_img/extra;
rm -rf $ROM_NAME $DTB_NAME

rm -rf /tmp/kernel/*.prop
# Change Kernel Name (Use 9 characters at version file)
cp -n $home/version /tmp/kernel/
kernel_name=$(cat /tmp/kernel/version);
ui_print " ";
ui_print "Kernel Name: $kernel_name";
rm -rf /tmp/kernel/version
# Patch Kernel Freq Control Cmdline If Exists
if [ $BIGCPUMAX_FREQ ] && [ $LITTLECPUMAX_FREQ ] && [ $BIGCPUMIN_FREQ ] && [ $LITTLECPUMIN_FREQ ] && [ $kernel_name ] && [ $SELINUX_MODE ]; then
  ui_print " ";
  ui_print "Applying Overclock:";
  ui_print "  Big Cpu Max Freq: $BIGCPUMAX_FREQ";
  sleep 1
  patch_cmdline "cpu_max_c2" "cpu_max_c2=$BIGCPUMAX_FREQ";
  ui_print "  Little Cpu Max Freq: $LITTLECPUMAX_FREQ";
  sleep 1
  patch_cmdline "cpu_max_c1" "cpu_max_c1=$LITTLECPUMAX_FREQ";

  echo "    write /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq $BIGCPUMAX_FREQ" >> $init_mod
  sed -i "/-xxTR-00.0/ s//-$kernel_name/g;/custom_enforcing=0/ s//custom_enforcing=$SELINUX_MODE/g;/cpu_max_c2=2704000/ s//cpu_max_c2=$BIGCPUMAX_FREQ/g;/cpu_min_c2=598000/ s//cpu_min_c2=$BIGCPUMIN_FREQ/g;/cpu_max_c1=1794000/ s//cpu_max_c1=$LITTLECPUMAX_FREQ/g;/cpu_min_c1=455000/ s//cpu_min_c1=$LITTLECPUMIN_FREQ/g" $home/Image;
elif [ $kernel_name ] && [ $SELINUX_MODE ]; then
  echo "    write /sys/devices/system/cpu/cpufreq/policy4/scaling_max_freq 2704000" >> $init_mod
  sed -i "/-xxTR-00.0/ s//-$kernel_name/g;/custom_enforcing=0/ s//custom_enforcing=$SELINUX_MODE/g" $home/Image;
fi;
if [ $rom_number != 3 ]; then
  rm -f /vendor/etc/init/init.services.rc;
  cp -f $init_mod /odm/etc/init/;
else
  rm -f /odm/etc/init/init.services.rc;
  cp -f $init_mod /vendor/etc/init/;
fi;
# end kernel changes