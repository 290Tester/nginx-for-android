#! /bin/bash
wget -q https://dl.google.com/android/repository/android-ndk-r27b-linux.zip
unzip -q android-ndk-r27b-linux.zip
export NDK="$PWD/android-ndk-r27b"
export CC="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android35-clang"
export CXX="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin/aarch64-linux-android35-clang++"
export PATH="$NDK/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH"
export CFLAGS="-fPIE -fPIC"
./Configuration.nginx