FROM debian:13 AS builder

RUN apt update && apt install -y \
    wget curl make cmake git p7zip tar gzip unzip
    
ENV PATH=/opt/android-ndk-r29/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH
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

RUN wget -q https://dl.google.com/android/repository/android-ndk-r29-linux.zip -O /opt/android-ndk-r29-linux.zip && \
    cd /opt && \
    unzip android-ndk-r29-linux.zip && \
    rm -f android-ndk-r29-linux.zip

WORKDIR /data/web/nginx

RUN wget -q https://github.com/290Tester/nginx-for-android/releases/download/nginx-base-libs/nginx-base-libs.tar.gz && \
    tar xf nginx-base-libs.tar.gz

RUN wget -q http://nginx.org/download/nginx-1.29.5.tar.gz && \
    tar xf nginx-1.29.5.tar.gz

WORKDIR /data/web/nginx/nginx-1.29.5
RUN wget -q https://github.com/290Tester/nginx-for-android/releases/download/nginx-base-libs/nginx.config && \
    chmod 755 nginx.config && \
    ./nginx.config

RUN make -j4 && make install -j4

RUN cd /data/web/nginx && \
    tar czf /tmp/nginx-android-aarch64.tar.gz \
    sbin/ lib/ etc/ var/ include/ && \
    echo "=== Build complete ===" && \
    ls -lh /tmp/nginx-android-aarch64.tar.gz

FROM scratch AS export
COPY --from=builder /tmp/nginx-android-aarch64.tar.gz /nginx-android-aarch64.tar.gz
