#!/bin/bash

. variables.sh

clean_temp

printf "Building for device: star2lte\n"

cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
cat $CUR_DIR/arch/arm64/configs/exynos9810-starxlte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
cat $CUR_DIR/arch/arm64/configs/exynos9810-star2lte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig

if [ ! -d $CUR_DIR/toolchain/clang ] || [ ! -f $CUR_DIR/toolchain/clang/clang ]; then
  tc_setup
fi

if [ ! -z "$1" ]; then  
  if [ "$1" == "stock" ]; then
    patch_stock
  elif [ "$1" == "aosp" ]; then
    patch_aosp
  fi
fi

if [ ! -z "$2" ]; then
  if [ "$2" == "ksu" ]; then  
    enable_kernelsu
  elif [ "$2" == "noksu" ]; then
    disable_kernelsu
  fi
fi

if [ ! -z "$3" ]; then
  if [ "$3" == "erofs" ]; then  
    dts_erofs
  elif [ "$3" == ext4 ]; then
    dts_ext4
  fi
fi

make exynos9810_temp_defconfig -j$(nproc --all)
make -j$(nproc --all)

printf $KERNEL_NAME

if [ ! -d $KERN_DIR/$KERNEL_NAME/star2lte ]; then
  mkdir -p $KERN_DIR/$KERNEL_NAME/star2lte
fi

if [ ! -d $KERN_DIR/$DTB_NAME/star2lte ]; then
  mkdir -p $KERN_DIR/$DTB_NAME/star2lte
fi

if [ ! -f $CUR_DIR/arch/arm64/boot/Image ] || [ ! -f $CUR_DIR/arch/arm64/boot/dtb.img ]; then
  printf "Operation completed with errors!\n"
else
  cp -vr $CUR_DIR/arch/arm64/boot/Image $KERN_DIR/$KERNEL_NAME/star2lte/zImage
  cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $KERN_DIR/$DTB_NAME/star2lte/dtb.img
  printf "Success!\n"
fi
