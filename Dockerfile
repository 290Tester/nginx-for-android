FROM debian:13 AS builder

RUN apt update && apt install -y \
    wget curl make cmake git p7zip-full tar gzip unzip

ENV NDK_PATH=/opt/android-ndk-r29
ENV PATH=${NDK_PATH}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

ENV CC=aarch64-linux-android35-clang
ENV CXX=aarch64-linux-android35-clang++
ENV AR=llvm-ar
ENV AS=llvm-as
ENV LD=ld.lld
ENV RANLIB=llvm-ranlib
ENV STRIP=llvm-strip
ENV CFLAGS="-fPIC -fPIE"
ENV LDFLAGS="-fPIE -fPIC"
ENV ngprefix=/data/web/nginx

RUN wget -q https://dl.google.com/android/repository/android-ndk-r29-linux.zip -O /opt/ndk.zip && \
    cd /opt && \
    unzip ndk.zip && \
    rm ndk.zip

WORKDIR /data/web/nginx

RUN wget -q https://github.com/290Tester/nginx-for-android/releases/download/nginx-base-libs/nginx-base-libs.tar.gz && \
    tar xf nginx-base-libs.tar.gz

RUN wget -q http://nginx.org/download/nginx-1.29.5.tar.gz && \
    tar xf nginx-1.29.5.tar.gz

WORKDIR /data/web/nginx/nginx-1.29.5

RUN ./configure --prefix="/data/web/nginx" \
--sbin-path="${ngprefix}/sbin/nginx" \
--modules-path="${ngprefix}/lib/modules" \
--conf-path="${ngprefix}/etc/nginx.conf" \
--error-log-path="${ngprefix}/var/errors.log" \
--pid-path="${ngprefix}/var/nginx.pid" \
--lock-path="${ngprefix}/var/lock" \
--build="Builder: Segmentation fault" \
--with-select_module \
--with-poll_module \
--with-threads \
--with-file-aio \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_v3_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_auth_request_module \
--with-http_random_index_module \
--with-http_secure_link_module \
--with-http_slice_module \
--http-log-path="${ngprefix}/var/access.log" \
--http-client-body-temp-path="${ngprefix}/var/up" \
--http-proxy-temp-path="${ngprefix}/var/proxy" \
--http-fastcgi-temp-path="${ngprefix}/var/proxy-fast" \
--http-uwsgi-temp-path="${ngprefix}/var/proxy-uwsgi" \
--http-scgi-temp-path="${ngprefix}/var/proxy-scgi" \
--with-stream \
--with-stream_ssl_module \
--with-stream_realip_module \
--with-stream_ssl_preread_module \
--with-pcre="${ngprefix}" \
--with-zlib="${ngprefix}" \
--with-openssl="${ngprefix}" \
--with-cc="${CC}" \
--with-cpp="${CC} -E" \
--with-cc-opt="-I/data/web/nginx/include -fPIC -fPIE -D__USE_GNU" \
--with-ld-opt="-L/data/web/nginx/lib -lssl -lcrypt -lcrypto -lpcre -lz -Wl,-rpath=/data/web/nginx/lib" \
--with-debug

RUN make -j$(nproc) && make install -j$(nproc)

RUN cd /data/web/nginx && \
    tar czf /tmp/nginx-android-aarch64.tar.gz sbin/ lib/ etc/ var/ include/ && \
    ls -lh /tmp/nginx-android-aarch64.tar.gz

FROM scratch AS export
COPY --from=builder /tmp/nginx-android-aarch64.tar.gz /nginx-android-aarch64.tar.gz
