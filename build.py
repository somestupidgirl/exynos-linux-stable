#!/usr/bin/python3

import os
import sys
import subprocess

def clean_all():
	subprocess.call(['bash', './clean.sh', 'all'])

def create_zip():
	subprocess.call(['bash', './zip.sh'])

def build_crown():
	subprocess.call(['bash', './buildN9.sh', '-k', 'stock', '-d', 'erofs', '-r', 'kernelsu', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildN9.sh', '-k', 'stock', '-d', 'ext4', '-r', 'magisk', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildN9.sh', '-k', 'aosp', '-d', 'erofs', '-r', 'kernelsu', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildN9.sh', '-k', 'aosp', '-d', 'ext4', '-r', 'magisk', '-n'])
	subprocess.call(['bash', './clean.sh'])

def build_star():
	subprocess.call(['bash', './buildS9.sh', '-k', 'stock', '-d', 'erofs', '-r', 'kernelsu', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildS9.sh', '-k', 'stock', '-d', 'ext4', '-r', 'magisk', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildS9.sh', '-k', 'aosp', '-d', 'erofs', '-r', 'kernelsu', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildS9.sh', '-k', 'aosp', '-d', 'ext4', '-r', 'magisk', '-n'])
	subprocess.call(['bash', './clean.sh'])

def build_star2():
	subprocess.call(['bash', './buildS9+.sh', '-k', 'stock', '-d', 'erofs', '-r', 'kernelsu', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildS9+.sh', '-k', 'stock', '-d', 'ext4', '-r', 'magisk', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildS9+.sh', '-k', 'aosp', '-d', 'erofs', '-r', 'kernelsu', '-n'])
	subprocess.call(['bash', './clean.sh'])
	subprocess.call(['bash', './buildS9+.sh', '-k', 'aosp', '-d', 'ext4', '-r', 'magisk', '-n'])
	subprocess.call(['bash', './clean.sh'])

def build_all():
	clean_all()
	build_crown()
	build_star()
	build_star2()
	create_zip()

def show_help():
	print("Usage:")
	print("    $ ./build <option>")
	print("")
	print("Options:")
	print("    all       Build all kernels and create flashable zip")
	print("    crown     Build for device crownlte (SM-N960/N960F)")
	print("    star      Build for device starlte (SM-G960)")
	print("    star2     Build for device star2lte (SM-G965)")
	print("")
	print("    zip       Create flashable zip")
	print("    clean     Full cleanup of the build environment")
	print("")

CUR_DIR = os.getcwd()

def main():
    os.chdir(CUR_DIR)

    if len(sys.argv) > 1:
        if sys.argv[1] == "all":
            build_all()
        elif sys.argv[1] == "crown":
            build_crown()
        elif sys.argv[1] == "star":
            build_star()
        elif sys.argv[1] == "star2":
            build_star2()
        if sys.argv[1] == "zip":
            create_zip()
        if sys.argv[1] == "clean":
            clean_all()
    else:
    	show_help()

if __name__ == "__main__":
    main()
