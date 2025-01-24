#!/bin/bash

printf "Creating High Compressed Kernel Files\n"
if [ -f Kernel.tar ]; then rm Kernel.tar; fi
if [ -f Kernel.tar.zst ]; then rm Kernel.tar.zst; fi
tar cf Kernel.tar Dtb* Kernel* empty-boot.img

echo -n "empty" > include
if [ "$(du -shb "Kernel" | cut -f1)" -ge "10835283" ] ;
then
	echo -n "kernel" > include
	if [ "$(du -shb "Kernel-stock" | cut -f1)" -ge "10835283" ] ;
	then
		echo -n "+stock" >> include
		if [ "$(du -shb "Kernel-aosp" | cut -f1)" -ge "10835283" ] ;
		then
			echo -n "+aosp" >> include
		fi
	fi
fi

echo -n "empty" > include-ksu
if [ "$(du -shb "Kernel-ksu" | cut -f1)" -ge "10835283" ] ;
then
	echo -n "kernel" > include-ksu
	if [ "$(du -shb "Kernel-stock-ksu" | cut -f1)" -ge "10835283" ] ;
	then
		echo -n "+stock" >> include-ksu
		if [ "$(du -shb "Kernel-aosp-ksu" | cut -f1)" -ge "10835283" ] ;
		then
			echo -n "+aosp" >> include-ksu
		fi
	fi
fi

echo -n "empty" > dts
if [ "$(du -shb "Dtb" | cut -f1)" -ge "20480" ] ;
then
	echo -n "ext4" > dts
fi
if [ "$(du -shb "Dtb-erofs" | cut -f1)" -ge "20480" ] ;
then
	echo -n "erofs" > dts
fi
if [ "$(du -shb "Dtb-erofs" | cut -f1)" -ge "20480" ] && [ "$(du -shb "Dtb" | cut -f1)" -ge "20480" ] ;
then
	echo -n "both" > dts
fi
filesize=$(wc -c "Kernel.tar" | awk '{print $1}')
zstd --ultra -22 --single-thread -v --zstd=strategy=9 --stream-size=$filesize --size-hint=$filesize Kernel.tar
if zstd -t "Kernel.tar.zst" ; then
	printf "Creating Kernel Flasher Zip\n"
	if [ -f xxmustafacooTR.zip ]; then rm xxmustafacooTR.zip; fi
	zip -9 -r xxmustafacooTR.zip META-INF Kernel.tar.zst LICENSE README.md modules ramdisk version include include-ksu dts anykernel.sh patch tools zip.sh xxTR
	printf "Done!\n"
else
    printf "Error in zstd archive!\n"
fi
