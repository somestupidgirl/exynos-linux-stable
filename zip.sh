#!/bin/bash

. variables.sh

printf "Creating flashable zip...\n"

cp -R $BUILD_DIR/Kernel-aosp $BUILD_DIR/Kernel
cp -R $BUILD_DIR/Kernel-aosp-ksu $BUILD_DIR/Kernel-ksu

# Copy kernel and dtb to boot dir
if [ -f $BUILD_DIR/Kernel/crownlte/zImage ]; then
  cp $BUILD_DIR/Kernel/crownlte/zImage $BOOT_DIR/split/kernel
else
  printf "ERROR: file: $BUILD_DIR/Kernel/crownlte/zImage not found"
  exit 1
fi

if [ -f $BUILD_DIR/Dtb/crownlte/dtb.img ]; then
  cp $BUILD_DIR/Dtb/crownlte/dtb.img $BOOT_DIR/split/extra
else
  printf "ERROR: file: $BUILD_DIR/Dtb/crownlte/dtb.img not found"
  exit 1
fi

# Repack boot.img
cd $BOOT_DIR && repackimg

# Move boot.img to Kernel directory
if [ -f $BOOT_DIR/new-boot.img ]; then
  mv $BOOT_DIR/new-boot.img $BUILD_DIR/empty-boot.img
else
  printf "ERROR: file: $BOOT_DIR/new-boot.img not found"
  exit 1
fi

# Copy resources and generate flashable zip

if [ -f $MOD_DIR/*.ko ]; then
  cp MOD_DIR/*.ko $ZIP_DIR/modules/system/lib/modules
fi

if [ -d $BUILD_DIR ]; then
  cp -R $BUILD_DIR/* $ZIP_DIR && cd $ZIP_DIR && ./zip.sh

  # Create Output directory
  if [ ! -d $OUT_DIR ]; then
    mkdir -p $OUT_DIR
  fi

  # Move $ZIP_NAME.zip to Output directory
  mv $ZIP_DIR/$ZIP_NAME.zip $OUT_DIR/$ZIP_NAME.zip
else
  printf "ERROR: directory: $BUILD_DIR not found"
  exit 1
fi

# Cleanup
rm -rf Dtb Dtb-erofs Kernel Kernel-ksu \
        Kernel-stock Kernel-stock-ksu \
        Kernel-aosp Kernel-aosp-ksu \
        Kernel.tar Kernel.tar.zst \
        empty-boot.img

rm $ZIP_DIR/modules/system/lib/modules/*.ko

cd $BOOT_DIR/split && \
        rm extra && \
        rm kernel && \
        rm ramdisk.cpio

# Return to build directory
cd $CUR_DIR

printf "Flashable zip is ready at $OUT_DIR/$ZIP_NAME.zip\n"
