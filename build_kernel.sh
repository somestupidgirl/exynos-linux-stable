#!/bin/bash

. variables.sh

if [ ! -d $CUR_DIR/toolchain/clang ] || [ ! -f $CUR_DIR/toolchain/clang/clang ]; then
  tc_setup
fi

. clean.sh all

# Galaxy Note 9 (crownlte)
. buildN9.sh stock ksu erofs
. buildN9.sh stock ksu ext4
. clean.sh
. buildN9.sh stock noksu erofs
. buildN9.sh stock noksu ext4
. clean.sh
. buildN9.sh aosp ksu erofs
. buildN9.sh aosp ksu ext4
. clean.sh
. buildN9.sh aosp noksu erofs
. buildN9.sh aosp noksu ext4
. clean.sh

# Galaxy S9 (starlte)
. buildS9.sh stock ksu erofs
. buildS9.sh stock ksu ext4
. clean.sh
. buildS9.sh stock noksu erofs
. buildS9.sh stock noksu ext4
. clean.sh
. buildS9.sh aosp ksu ext4
. buildS9.sh aosp ksu erofs
. clean.sh
. buildS9.sh aosp noksu erofs
. buildS9.sh aosp noksu ext4
. clean.sh

# Galaxy S9+
. buildS9+.sh stock ksu erofs
. buildS9+.sh stock ksu ext4
. clean.sh
. buildS9+.sh stock noksu erofs
. buildS9+.sh stock noksu ext4
. clean.sh
. buildS9+.sh aosp ksu erofs
. buildS9+.sh aosp ksu ext4
. clean.sh
. buildS9+.sh aosp noksu erofs
. buildS9+.sh aosp noksu ext4
. clean.sh

. zip.sh
