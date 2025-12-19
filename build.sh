#!/bin/bash
mkdir -p /data/web/Nginx
cd /data/web/Nginx
echo ">>> Downloading NDK r27b..."
wget -q https://dl.google.com/android/repository/android-ndk-r27b-linux.zip
unzip -q android-ndk-r27b-linux.zip
rm -f android-ndk-r27b-linux.zip
export NDK_ROOT="$PWD/android-ndk-r27b"
export PATH="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
TOOLCHAIN="$NDK_ROOT/toolchains/llvm/prebuilt/linux-x86_64"
export CC=$TOOLCHAIN/bin/aarch64-linux-android34-clang
export CXX=$TOOLCHAIN/bin/aarch64-linux-android34-clang++
export CPP="$CC -E"
export cross_compiling=yes
export LD=$TOOLCHAIN/bin/ld
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export CFLAGS="-fPIE -fPIC"
echo ">>> Extracting..."
wget "https://github.com/nginx/nginx/releases/download/release-1.29.4/nginx-1.29.4.tar.gz"
tar -xf "nginx-1.29.4.tar.gz"
wget "https://github.com/290Tester/nginx-for-android/releases/download/v1.29.4/Build-dep.tar.gz"
tar -xf "Build-dep.tar.gz"
echo ">>> Configuring nginx..."
cd "nginx-1.29.4"
ls -l $CC
$CC --version
wget "https://github.com/290Tester/nginx-for-android/releases/download/v1.29.4/nginx-1.29.4-Makefile.tar.gz"
tar xf nginx-1.29.4-Makefile.tar.gz
echo ">>> Building..."
cat objs/autoconf.err
make -j$(nproc)
echo ">>> Installing..."
make -j3 install 
echo ">>> Packing..."
tar -C /data/web -cJf ~/nginx-android-aarch64.tar.xz Nginx
cd -
echo ">>> Done: nginx-android-aarch64.tar.xz"
