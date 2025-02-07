# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=starlte
device.name4=starltexx
device.name2=star2lte
device.name5=star2ltexx
device.name3=crownlte
device.name6=crownltexx
supported.versions=
supported.patchlevels=
'; } # end properties

### AnyKernel install
# begin attributes
attributes() {
set_perm_recursive 0 0 755 644 $ramdisk/*;
set_perm_recursive 0 0 750 750 $ramdisk/init* $ramdisk/sbin;
} # end attributes

## boot shell variables
# xxTR Start
if [ $(cat /tmp/aroma/rom.prop | cut -d '=' -f2) = 5 ]; then
  ui_print "Flashing to Recovery";
  block=/dev/block/platform/11120000.ufs/by-name/RECOVERY;
else
  block=/dev/block/platform/11120000.ufs/by-name/BOOT;
fi;
# xxTR Finish
is_slot_device=auto;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh && attributes;

# xxTR Start
. $home/xxTR/setup.sh;
# xxTR Finish

# boot install
dump_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot ramdisk

# mount vendor
mount -o remount,rw /vendor;

# xxTR Start
. $home/xxTR/custom.sh;
. $home/xxTR/finish.sh;
# xxTR Finish

write_boot;
## end boot install