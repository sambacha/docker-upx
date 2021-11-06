FROM buildpack-deps:focal AS base
LABEL version="8"


ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -qqy --no-install-recommends \
		build-essential \
		software-properties-common \
		cmake ninja-build sed core-utils \
		libboost-filesystem-dev libboost-test-dev libboost-system-dev \
		libboost-program-options-dev \
		libcvc4-dev libz3-static-dev z3-static \
		libbz2-dev zlib1g-dev git curl uuid-dev \
		pkg-config liblzma-dev unzip mlton m4; \
	    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
		gcc \
		libc-dev \
		libssl-dev \
		zlib1g-dev \
	rm -rf /var/lib/apt/lists/*; \
	apt-get purge -y --auto-remove

FROM base AS libraries

ENV LDFLAGS=-static

ENV UCL_VER 1.03
RUN curl -L http://www.oberhumer.com/opensource/ucl/download/ucl-${UCL_VER}.tar.gz|tar -xzv \
    && cd ucl-${UCL_VER} \
#    export CFLAGS="$CFLAGS -std=c90 -fPIC" \
    && ./configure CFLAGS="$CFLAGS -std=c90 -fPIC" \
    && make \
    && make install

ENV LZMA_VER 920
RUN curl -LO http://www.7-zip.org/a/lzma${LZMA_VER}.tar.bz2 \
    && bunzip2 lzma${LZMA_VER}.tar.bz2 \
    && tar -xvf lzma${LZMA_VER}.tar
ENV UPX_LZMADIR /

VOLUME /release

ENV UPX_UCLDIR=/ucl-${UCL_VER}
ENV UPX_VER 3.96

COPY upx-3.96-src/ upx-3.96-src/
RUN cd upx-3.96-src \
    && sed -i "/addLoad/ s/NULL/(char*)NULL/" src/packer.cpp \
    && make all

CMD /upx-${UPX_VER}-amd64_linux/src/upx.out --best --ultra-brute -o/release/upx /upx-${UPX_VER}-amd64_linux/src/upx.out
