#!/bin/bash

. variables.sh

DEVICE_NAME="star2lte"

while getopts k:d:r:hn flag; do
  case ${flag} in
    k) # Kernel type
      KERNEL_TYPE=$OPTARG;;
    d) # DTB filesystem
      DTB_FS_TYPE=$OPTARG;;
    r) # Patch KernelSU/Magisk
      ROOT_METHOD=$OPTARG;;
    h) # display Help
      show_help
      exit;;
    n)
      NETHUNTER=true;;
    \?) # Invalid option
      echo "Error: Invalid option"
      exit;;
    *) # No input
      help
      exit;;
   esac
done
shift "$((OPTIND-1))"

clean_temp

if [ ! -d $CUR_DIR/toolchain/clang ] || [ ! -f $CUR_DIR/toolchain/clang/clang ]; then
  tc_setup
fi

printf "Building for device: $DEVICE_NAME\n"
cp -vr $CUR_DIR/arch/arm64/configs/exynos9810_defconfig $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
cat $CUR_DIR/arch/arm64/configs/exynos9810-starxlte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
echo "" >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig
cat $CUR_DIR/arch/arm64/configs/exynos9810-star2lte_defconfig >> $CUR_DIR/arch/arm64/configs/exynos9810_temp_defconfig

if [ "$KERNEL_TYPE" == "stock" ]; then
  enable_stock
elif [ "$KERNEL_TYPE" == "aosp" ]; then
  enable_aosp
fi

if [ "$DTB_FS_TYPE" == "erofs" ]; then  
  dts_erofs
elif [ "$DTB_FS_TYPE" == ext4 ]; then
  dts_ext4
fi

if [ "$ROOT_METHOD" == "kernelsu" ]; then  
  enable_kernelsu
elif [ "$ROOT_METHOD" == "magisk" ]; then
  disable_kernelsu
fi

if [ "$NETHUNTER" == true ]; then  
  enable_nethunter
elif [ "$NETHUNTER" == false ]; then
  disable_nethunter
fi

make exynos9810_temp_defconfig -j$(nproc --all)
make -j$(nproc --all)

printf $KERNEL_NAME

if [ ! -d $BUILD_DIR/$KERNEL_NAME/$DEVICE_NAME ]; then
  mkdir -p $BUILD_DIR/$KERNEL_NAME/$DEVICE_NAME
fi

if [ ! -d $BUILD_DIR/$DTB_NAME/$DEVICE_NAME ]; then
  mkdir -p $BUILD_DIR/$DTB_NAME/$DEVICE_NAME
fi

if [ -f $CUR_DIR/**/*.ko ]; then
  mkdir $ANDROID_DIR/modules
  cp $CUR_DIR/**/*.ko $MOD_DIR
fi

if [ ! -f $CUR_DIR/arch/arm64/boot/Image ] || [ ! -f $CUR_DIR/arch/arm64/boot/dtb.img ]; then
  printf "\n"
  printf "Operation completed with errors!\n"
  exit 1
else
  cp -vr $CUR_DIR/arch/arm64/boot/Image $BUILD_DIR/$KERNEL_NAME/$DEVICE_NAME/zImage
  cp -vr $CUR_DIR/arch/arm64/boot/dtb.img $BUILD_DIR/$DTB_NAME/$DEVICE_NAME/dtb.img
  printf "\n"
  printf "Build successful!\n"
fi
