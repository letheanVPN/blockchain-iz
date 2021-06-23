#!/usr/bin/env bash

# OpenSSL
export OPENSSL_VERSION=1.1.0h
export OPENSSL_HASH=5835626cde9e99656585fc7aaa2302a73a7e1340bf8c14fd635a62c66802a517
export OPENSSL_ROOT_DIR="build/openssl-${OPENSSL_VERSION}"
# Boost
export BOOST_VERSION=1_58_0
export BOOST_VERSION_DOT=1.58.0
export BOOST_HASH=fdfc204fc33ec79c99b9a74944c3e54bd78be4f7f15e260c0e2700a36dc7d3e5
export BOOST_ROOT="build/boost_${BOOST_VERSION}"

echo "Compiling OpenSSL"
set -ex \
    && mkdir -p "${OPENSSL_ROOT_DIR}" \
    && cd "${OPENSSL_ROOT_DIR}" \
    && curl -s -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" \
    && echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf "openssl-${OPENSSL_VERSION}.tar.gz" \
    && cd "openssl-${OPENSSL_VERSION}" \
    && ./Configure linux-x86_64 no-shared --static -fPIC \
    && make build_generated \
    && make libcrypto.a \
    && cd ..
#    && make install

echo "Compiling OpenSSL"

set -ex \
    && mkdir -p "${BOOST_ROOT}" \
    && cd "${BOOST_ROOT}" \
    && curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2 \
    && echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
    && tar -xvf "boost_${BOOST_VERSION}.tar.bz2" \
    && cd "boost_${BOOST_VERSION}" \
    && ./bootstrap.sh \
    && ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" stage


