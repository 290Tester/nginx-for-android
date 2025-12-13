#!/bin/bash
set -e

# 1. 下载 NDK ----------------------------------------------------------
echo ">>> Downloading NDK r27b..."
wget -q https://dl.google.com/android/repository/android-ndk-r27b-linux.zip
unzip -q android-ndk-r27b-linux.zip
rm -f android-ndk-r27b-linux.zip
export NDK_ROOT="$PWD/android-ndk-r27b"
export PATH="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"

# 2. 导出交叉编译变量 ---------------------------------------------------
TOOLCHAIN="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"
export CC=$TOOLCHAIN/bin/aarch64-linux-android35-clang
export CXX=$TOOLCHAIN/bin/aarch64-linux-android35-clang++
export CPP="$CC -E"
export LD=$TOOLCHAIN/bin/ld
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export CFLAGS="-fPIE -fPIC"
export PKG_CONFIG_PATH="$PWD/data/web/Nginx/lib/pkgconfig"

# 3. 依赖包 -------------------------------------------------------------
echo ">>> Extracting depend..."
tar -xf depend.tar.gz

# 4. 生成 Makefile ------------------------------------------------------
echo ">>> Configuring nginx..."
chmod +x Configuration.nginx
./Configuration.nginx

# 5. 编译 & 安装 ---------------------------------------------------------
echo ">>> Building..."
make -j$(nproc)
echo ">>> Installing..."
make install DESTDIR="$PWD/install"

# 6. 打包 --------------------------------------------------------------
echo ">>> Packing..."
cd install/data/web
tar -cJf ../../../../nginx-android-aarch64.tar.xz Nginx/
cd ../../../

echo ">>> Done: nginx-android-aarch64.tar.xz"
