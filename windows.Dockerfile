# Uses a pre configured ubuntu:16.04 image
FROM registry.gitlab.com/lethean.io/devops:latest as builder

# Where all the works done.
WORKDIR /usr/src

RUN apt update && apt install -y mingw-w64 mingw-w64-common mingw-w64-i686-dev gcc-mingw-w64-x86-64 \
                   mingw-w64-tools mingw-w64-x86-64-dev curl gcc-mingw-w64-i686

RUN apt remove -y libunbound-dev
#ARG CROSS_COMPILE=CROSS_COMPILE
# OpenSSL
ARG OPENSSL_VERSION=1.1.0j
ARG OPENSSL_HASH=31bec6c203ce1a8e93d5994f4ed304c63ccf07676118b6634edded12ad1b3246
RUN curl -s -O https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz \
    && echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf openssl-${OPENSSL_VERSION}.tar.gz \
    && cd openssl-${OPENSSL_VERSION} \
    && ./Configure mingw64 no-asm no-shared --static --cross-compile-prefix=x86_64-w64-mingw32- --prefix=/usr/lib/mingw64  \
    && make build_generated \
    && make libcrypto.a \
    && make install



RUN apt install -y binutils-mingw-w64-i686 g++-mingw-w64-i686 g++-mingw-w64-x86-64 \
    && update-alternatives --set i686-w64-mingw32-g++ /usr/bin/i686-w64-mingw32-g++-posix \
    && update-alternatives --set i686-w64-mingw32-gcc /usr/bin/i686-w64-mingw32-gcc-posix \
    && update-alternatives --set x86_64-w64-mingw32-g++ /usr/bin/x86_64-w64-mingw32-g++-posix \
    && update-alternatives --set x86_64-w64-mingw32-gcc /usr/bin/x86_64-w64-mingw32-gcc-posix

## Boost
ARG BOOST_VERSION=1_68_0
ARG BOOST_VERSION_DOT=1.68.0
ARG BOOST_HASH=7f6130bc3cf65f56a618888ce9d5ea704fa10b462be126ad053e80e553d6d8b7
RUN set -ex \
    && curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://dl.bintray.com/boostorg/release/${BOOST_VERSION_DOT}/source/boost_${BOOST_VERSION}.tar.bz2 \
    && echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
    && tar -xvf boost_${BOOST_VERSION}.tar.bz2 \
    && cd boost_${BOOST_VERSION} && echo "using gcc :  : x86_64-w64-mingw32-g++ ;" > user-config.jam \
    && ./bootstrap.sh --with-toolset=gcc --prefix=/usr/lib/ming64/boost_${BOOST_VERSION} \
    && ./b2 --prefix=/usr/lib/ming64/boost --build-type=minimal --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread  \
     --user-config=./user-config.jam address-model=64 target-os=windows variant=release install

ENV BOOST_ROOT "/usr/lib/ming64/boost_${BOOST_VERSION}"

ENV OPENSSL_ROOT_DIR "/usr/lib/mingw64/ssl"


WORKDIR /usr/local/src/lethean.io/blockchain/lethean

COPY . .

# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static

# if you want to clear build, purge the runner cache/prune the builder
RUN rm -rf build && make ${RELEASE_TYPE}

# New image, changes output image to a fresh Ubuntu image.
FROM ubuntu:16.04

# grab the files made in the builder stage
COPY --from=builder /usr/local/src/lethean.io/blockchain/lethean/build/release/bin /usr/local/bin


#ENTRYPOINT ["letheand", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=48772", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=48782", "--non-interactive", "--confirm-external-bind"]

