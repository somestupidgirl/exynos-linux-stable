#!/bin/bash

. variables.sh

printf "Creating flashable zip...\n"

cp -R $KERN_DIR/Kernel-stock $KERN_DIR/Kernel

# Copy kernel and dtb to boot image base
cp $KERN_DIR/Kernel/crownlte/zImage $BOOT_DIR/split/kernel
cp $KERN_DIR/Dtb/crownlte/dtb.img $BOOT_DIR/split/extra

# Repack empty-boot.img
cd $BOOT_DIR && repackimg

# Move empty-boot.img to Kernel directory
mv $BOOT_DIR/new-boot.img $KERN_DIR/empty-boot.img

# Compress Kernel.tar.zst
cd $ZIP_DIR && tar --zstd -cf Kernel.tar.zst Kernel

# Move Kernel.tar.zst to Aroma directory
mv $ZIP_DIR/Kernel.tar.zst $ZIP_DIR/Aroma

# Zip the Aroma installer directory
cd $ZIP_DIR && zip -r -o Aroma.zip $ZIP_DIR/Aroma/*

# Create Output directory
if [ ! -d $OUT_DIR ]; then
  mkdir -p $OUT_DIR
fi

# Move Aroma.zip to Output directory
mv Aroma.zip $OUT_DIR/Aroma.zip

# Cleanup
git restore zip/Boot/split/kernel
git restore zip/Boot/split/ramdisk.cpio

# Return to build directory
cd $CUR_DIR

printf "Flashable zip is ready at $OUT_DIR/Aroma.zip\n"
