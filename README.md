Android kernel (Linux 4.9.y) for Samsung Exynos 9810 devices

Supported devices:

  * Samsung Galaxy S9 (starlte, G960)
  * Samsung Galaxy S9+ (star2lte, G965)
  * Samsung Galaxy Note 9 (crownlte, N960/N960F).

The kernel can be compiled "out-of-the-box" using the included build scripts without having to search for a proper cross-compile toolchain and/or setting up any environment variables. The build process is fully automated, from fetching the toolchain to generating a flashable zip.

To compile and zip all kernel versions, run:

    $ ./build_kernel.sh

To compile a single kernel for a specific device, run:

    $ ./build<DEV>.sh <SYS> <KSU> <DTS>

Available arguments:
    * Device   <DEV>  N9, S9, S9+
    * System   <SYS>  stock, aosp
    * KernelSU <KSU>  ksu, noksu
    * Dts FS   <DTS>  ext4, erofs

The compiler used is Clang version 19.0.1, from [android.googlesource.com](https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+/refs/tags/android-15.0.0_r12/clang-r536225/)

Binutils version 2.43, compiled using [tc-build](https://github.com/ClangBuiltLinux/tc-build).

[Magiskboot-based Android Image Kitchen](https://github.com/Shubhamvis98/AIK).

This project is a fork of: [xxmustafacooTR/exynos-linux-stable](https://github.com/xxmustafacooTR/exynos-linux-stable).
