#!/bin/bash

CUR_DIR=$PWD

ZIP_DIR="$CUR_DIR/zip"
BOOT_DIR="$ZIP_DIR/Boot"
KERN_DIR="$ZIP_DIR/Kernel"
OUT_DIR="$ZIP_DIR/Out"

KERNEL_NAME="Kernel"
DTB_NAME="Dtb"

tc_setup() {
	if [ ! -d $CUR_DIR/toolchain/clang ]; then
  		mkdir -p mkdir $CUR_DIR/toolchain/clang
	fi
	
	if [ ! -f $CUR_DIR/toolchain/clang/bin/clang ]; then
		printf "Fetching clang...\n"
		curl https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/tags/android-15.0.0_r12/clang-r536225.tar.gz --output $CUR_DIR/toolchain/clang/clang.tar.gz
	 	cd $CUR_DIR/toolchain/clang && tar xzvf clang.tar.gz && rm clang.tar.gz && cd $CUR_DIR
	fi

	if [ ! -d $CUR_DIR/toolchain/clang/aarch64-linux-gnu ]; then
		printf "Copying binutils...\n"
		cp -r $CUR_DIR/toolchain/binutils/* $CUR_DIR/toolchain/clang
	fi

	if [ -f $CUR_DIR/toolchain/clang/bin/clang ] && [ -d $CUR_DIR/toolchain/clang/aarch64-linux-gnu ]; then
		printf "Toolchain is ready at: $CUR_DIR/toolchain/clang\n"
		printf "Clang version: 19.0.1\n"
		printf "Binutils version: 2.43\n"
	else
		printf "ERROR: Toolchain: Something went wrong.\n"
		exit 1
	fi
}

export PATH=$CUR_DIR/toolchain/clang/bin:$CUR_DIR/toolchain/clang/lib:$CUR_DIR/zip/Boot/AIK-magisk/bin:${PATH}
export CLANG_TRIPLE=$CUR_DIR/toolchain/clang/bin/aarch64-linux-gnu-
export CROSS_COMPILE=$CUR_DIR/toolchain/clang/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=$CUR_DIR/toolchain/clang/bin/arm-linux-gnueabi-
export CC=$CUR_DIR/toolchain/clang/bin/clang
export REAL_CC=$CUR_DIR/toolchain/clang/bin/clang
export LD=$CUR_DIR/toolchain/clang/bin/ld.lld
export AR=$CUR_DIR/toolchain/clang/bin/llvm-ar
export NM=$CUR_DIR/toolchain/clang/bin/llvm-nm
export OBJCOPY=$CUR_DIR/toolchain/clang/bin/llvm-objcopy
export OBJDUMP=$CUR_DIR/toolchain/clang/bin/llvm-objdump
export READELF=$CUR_DIR/toolchain/clang/bin/llvm-readelf
export STRIP=$CUR_DIR/toolchain/clang/bin/llvm-strip

export LLVM=1 && export LLVM_IAS=1
export KALLSYMS_EXTRA_PASS=1

export ARCH=arm64 && export SUBARCH=arm64

dts_ext4() {
	printf "EXT4 Dts\n"

	sed -i 's|erofs|ext4|g' "$CUR_DIR"/arch/arm64/boot/dts/exynos/exynos9810-starlte_common.dtsi
	sed -i 's|erofs|ext4|g' "$CUR_DIR"/arch/arm64/boot/dts/exynos/exynos9810-star2lte_common.dtsi
	sed -i 's|erofs|ext4|g' "$CUR_DIR"/arch/arm64/boot/dts/exynos/exynos9810-crownlte_common.dtsi

	DTB_NAME="Dtb"
}

dts_erofs() {
	printf "EROFS Dts\n"

	sed -i 's|ext4|erofs|g' "$CUR_DIR"/arch/arm64/boot/dts/exynos/exynos9810-starlte_common.dtsi
	sed -i 's|ext4|erofs|g' "$CUR_DIR"/arch/arm64/boot/dts/exynos/exynos9810-star2lte_common.dtsi
	sed -i 's|ext4|erofs|g' "$CUR_DIR"/arch/arm64/boot/dts/exynos/exynos9810-crownlte_common.dtsi

	DTB_NAME="Dtb-erofs"
}

enable_kernelsu() {
	printf "Enabling KernelSU\n"

	KSU_KCONFIG="$CUR_DIR/drivers/Kconfig"
	KSU_MAKEFILE="$CUR_DIR/drivers/Makefile"

	if grep -q kernelsu "$KSU_KCONFIG"; then
		printf "KernelSU: drivers/Kconfig: No action needed\n"
	else
		sed -i 's|endmenu|source "drivers/kernelsu/Kconfig"\n\nendmenu\n|g' "$CUR_DIR"/drivers/Kconfig
	fi

	if grep -q kernelsu "$KSU_MAKEFILE"; then
		printf "KernelSU: drivers/Makefile: No action needed\n"
	else
		sed -i 's|#TZIC|obj-$(CONFIG_KSU) += kernelsu/\n\n#TZIC|g' "$CUR_DIR"/drivers/Makefile
	fi

	sed -i 's|# CONFIG_KSU is not set|CONFIG_KSU=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig

	KERNEL_NAME="$KERNEL_NAME-ksu"
}

disable_kernelsu() {
	printf "Disabling KernelSU\n"

	sed -i 's|CONFIG_KSU=y|# CONFIG_KSU is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig

	KERNEL_NAME="$KERNEL_NAME"
}

disable_hmp() {
	printf "Disabling HMP\n"

	KERNEL_NAME="$KERNEL_NAME"
}


patch_wifi() {
	printf "Patching Wifi to Old Driver\n"

	sed -i 's|CONFIG_BCMDHD_101_16=y|# CONFIG_BCMDHD_101_16 is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_BCMDHD_100_15 is not set|CONFIG_BCMDHD_100_15=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig

	KERNEL_NAME="Kernel-a11"
}

patch_stock() {
	printf "Patching Cached Defconfig For Stock Rom\n"

	sed -i 's|CONFIG_SECURITY_SELINUX_NEVER_ENFORCE=y|# CONFIG_SECURITY_SELINUX_NEVER_ENFORCE is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_HALL_NEW_NODE=y|# CONFIG_HALL_NEW_NODE is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_NETFILTER_XT_MATCH_OWNER=y|# CONFIG_NETFILTER_XT_MATCH_OWNER is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_NETFILTER_XT_MATCH_L2TP=y|# CONFIG_NETFILTER_XT_MATCH_L2TP is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_L2TP=y|# CONFIG_L2TP is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_NET_SCH_NETEM is not set|CONFIG_NET_SCH_NETEM=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_NET_CLS_CGROUP is not set|CONFIG_NET_CLS_CGROUP=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_NET_CLS_BPF=y|# CONFIG_NET_CLS_BPF is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_VSOCKETS=y|# CONFIG_VSOCKETS is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_CGROUP_NET_CLASSID is not set|CONFIG_CGROUP_NET_CLASSID=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_CUSTOM_FORCETOUCH=y|# CONFIG_CUSTOM_FORCETOUCH is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_NETFILTER_XT_MATCH_ONESHOT is not set|CONFIG_NETFILTER_XT_MATCH_ONESHOT=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_SEC_VIB_NOTIFIER=y|# CONFIG_SEC_VIB_NOTIFIER is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_SEC_VIBRATOR=y|# CONFIG_SEC_VIBRATOR is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_MAX77705_VIBRATOR=y|# CONFIG_MAX77705_VIBRATOR is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_SEC_HAPTIC is not set|CONFIG_SEC_HAPTIC=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_MOTOR_DRV_MAX77705 is not set|CONFIG_MOTOR_DRV_MAX77705=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|# CONFIG_MOTOR_DRV_MAX77865 is not set|CONFIG_MOTOR_DRV_MAX77865=y|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig

	patch_wifi

	echo "" >> "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	echo "CONFIG_TCP_CONG_LIA=y" >> "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	echo "CONFIG_TCP_CONG_OLIA=y" >> "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	echo "CONFIG_NETFILTER_XT_MATCH_QTAGUID=y" >> "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig

	KERNEL_NAME="Kernel-stock"
}

patch_aosp() {
	printf "Patching Cached Defconfig For AOSP Base\n"

	sed -i 's|CONFIG_USB_ANDROID_SAMSUNG_MTP=y|# CONFIG_USB_ANDROID_SAMSUNG_MTP is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_EXYNOS_DECON_MDNIE_LITE_TUNE_RESTRICTIONS=y|# CONFIG_EXYNOS_DECON_MDNIE_LITE_TUNE_RESTRICTIONS is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_ZRAM_LRU_WRITEBACK=y|# CONFIG_ZRAM_LRU_WRITEBACK is not set|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig
	sed -i 's|CONFIG_ZRAM_LRU_WRITEBACK_LIMIT=5120|CONFIG_ZRAM_LRU_WRITEBACK_LIMIT=1024|g' "$CUR_DIR"/arch/arm64/configs/exynos9810_temp_defconfig

	KERNEL_NAME="Kernel-aosp"
}

clean_external() {
	cd $CUR_DIR
	rm -rf .*-fetch-lock drivers/kernelsu/.check net/wireguard/.check
}

clean_temp() {
	cd $CUR_DIR
	rm -rf vmlinux.* drivers/gator_5.27/gator_src_md5.h scripts/dtbtool_exynos/dtbtool arch/arm64/boot/dtb.img arch/arm64/boot/dts/exynos/*dtb* arch/arm64/configs/exynos9810_temp_defconfig
}

clean_prebuilt() {
	cd $CUR_DIR
	rm -rf $KERN_DIR
}

clean_kernelsu() {
	cd $CUR_DIR
	rm -rf drivers/kernelsu
    git checkout --ours drivers/Kconfig
    git checkout --ours drivers/Makefile
    git checkout --ours arch/arm64/boot/dts/exynos/exynos9810-crownlte_common.dtsi
    git checkout --ours arch/arm64/boot/dts/exynos/exynos9810-star2lte_common.dtsi
    git checkout --ours arch/arm64/boot/dts/exynos/exynos9810-starlte_common.dtsi
}

clean() {
	cd $CUR_DIR
	clean_temp
    clean_external
    make -j$(nproc) clean
    make -j$(nproc) mrproper
}
