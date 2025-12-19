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
./configure \
--prefix=/data/web/Nginx \
--conf-path=/data/web/Nginx/etc/nginx.conf \
--error-log-path=/data/web/Nginx/var/error.log \
--http-log-path=/data/web/Nginx/var/log.log \
--pid-path=/data/web/Nginx/var/nginx.pid \
--lock-path=/data/web/Nginx/var/nginx.lock \
--http-client-body-temp-path=/data/web/Nginx/var/client_body_temp \
--http-proxy-temp-path=/data/web/Nginx/var/proxy_temp \
--http-fastcgi-temp-path=/data/web/Nginx/var/fastcgi_temp \
--http-uwsgi-temp-path=/data/web/Nginx/var/uwsgi_temp \
--http-scgi-temp-path=/data/web/Nginx/var/scgi_temp \
--with-pcre=/data/web/Nginx \
--with-openssl=/data/web/Nginx \
--with-zlib=/data/web/Nginx \
--with-pcre-opt=--host=aarch64-linux-android \
--with-cc=$CC \
--with-cc-opt='-I/data/web/Nginx/include -D__USE_GNU -Os -flto ' \
--with-ld-opt='-L/data/web/Nginx/lib -lz /data/web/Nginx/.libs/libpcre.a /data/web/Nginx/.openssl/lib/libssl.a /data/web/Nginx/.openssl/lib/libcrypto.a -Wl,-rpath,/data/web/Nginx/lib:/data/web/Nginx/lib64 -lz /data/web/Nginx/.libs/libpcre.a /data/web/Nginx/.openssl/lib/libssl.a /data/web/Nginx/.openssl/lib/libcrypto.a -Wl,--gc-sections -flto' \
--with-http_ssl_module \
--with-stream_ssl_module \
--with-http_v2_module \
--with-http_v3_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-http_realip_module \
--with-http_sub_module \
--with-http_secure_link_module \
--with-http_dav_module \
--with-http_addition_module \
--with-stream \
--with-http_auth_request_module \
--with-http_slice_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_random_index_module \
--with-http_degradation_module \
--with-stream_realip_module \
--with-stream_ssl_preread_module \
--with-file-aio \
--with-threads \
--with-compat \
--with-debug \
--with-poll_module \
--with-select_module
echo ">>> Building..."
make -j$(nproc)
echo ">>> Installing..."
make -j3 install 
echo ">>> Packing..."
tar -C /data/web -cJf ~/nginx-android-aarch64.tar.xz Nginx
cd -
echo ">>> Done: nginx-android-aarch64.tar.xz"
