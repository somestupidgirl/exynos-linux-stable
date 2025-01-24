### Variables and Setup

# begin variables
zstd=$home/xxTR/zstd
patch_date=$home/xxTR/patch_date
init_mod=$home/xxTR/init.services.rc
mkdir -p /tmp/kernel

cp -n /tmp/aroma/boot.prop /tmp/kernel/
cp -n /tmp/aroma/selinux.prop /tmp/kernel/
BOOT=$(cat /tmp/kernel/boot.prop | cut -d '=' -f2)
SELINUX=$(cat /tmp/kernel/selinux.prop | cut -d '=' -f2)
# end variables

# set permissions
chmod +x $zstd
chmod +x $patch_date
set_perm_recursive 0 0 755 755 $init_mod;

# Kernel files
$zstd -d -f $home/Kernel.tar.zst
rm $home/Kernel.tar.zst

# Mount Some Partitions
umount /system_root;
umount /system;
mount /system_root;
mount /system;
mount -o remount,rw /system_root;
mount -o remount,rw /system;

# begin boot extract
ui_print " ";
# Replace Boot with stock
if [ $BOOT = 3 ] || [ $BOOT = 4 ]; then
  ui_print "Using Current Boot Image";
else
  tar xf $home/Kernel.tar empty-boot.img
  # Broken for now
  #if [ -f "/system_root/system/build.prop" ]; then
    #date="$(file_getprop /system_root/system/build.prop ro.build.version.security_patch | cut -c1-7)"
  #elif [ -f "/system/build.prop" ]; then
    #date="$(file_getprop /system/build.prop ro.build.version.security_patch | cut -c1-7)"
  #fi
  if [[ ! -z $date ]]; then
    ui_print "Patching Clean Boot Image Date to: $date"
	# Script does validation of date
    $patch_date $date empty-boot.img
  fi
  dd if=empty-boot.img of=$block
  ui_print "Clean Boot Image Flashed";
  rm empty-boot.img
fi;

ui_print " ";
# Replace Selinux Mode
if [ $SELINUX = 1 ]; then
  ui_print "Selinux is Permissive";
  SELINUX_MODE="0"
elif [ $SELINUX = 2 ]; then
  ui_print "Selinux is Permissive but faked as Enforce";
  SELINUX_MODE="3"
elif [ $SELINUX = 3 ]; then
  ui_print "Selinux is Enforce";
  SELINUX_MODE="1"
else
  ui_print "Selinux is Controlled By Android System";
  SELINUX_MODE="4"
fi;
# end boot extract