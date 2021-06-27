#!/bin/bash

echo "We are now going to try and compile the libs we need on your machine"
echo "If this fails please report to our discord using the Website chat button"
echo "https://discord.lt.hn Please include the last error here, thank you, lets Compile!"

# base settings
BASE_DIR=$(pwd)
SRC_DIR="$(pwd)/build/libs/src"
INSTALL_DIR="$(pwd)/build/libs"
export BASE_DIR=$BASE_DIR
export SRC_DIR=$SRC_DIR
export INSTALL_DIR=$INSTALL_DIR

mkdir -p "${SRC_DIR}/arm8"

# OpenSSL Settings
OPENSSL_VERSION=1.1.0h
OPENSSL_HASH=5835626cde9e99656585fc7aaa2302a73a7e1340bf8c14fd635a62c66802a517
OPENSSL_SRC_DIR_ARM8="${SRC_DIR}/arm8"
OPENSSL_INSTALL_DIR_ARM8="${INSTALL_DIR}/arm8/openssl-${OPENSSL_VERSION}"
export OPENSSL_INSTALL_DIR_ARM8 OPENSSL_SRC_DIR_ARM8 OPENSSL_HASH OPENSSL_VERSION


#if [ ! -d "$OPENSSL_INSTALL_DIR_ARM8" ] && [ -d "$OPENSSL_SRC_DIR_ARM8/openssl-${OPENSSL_VERSION}" ]; then
#      set -x &&
#    cd "$OPENSSL_SRC_DIR_ARM8/openssl-${OPENSSL_VERSION}" &&
#    ./Configure linux-aarch64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR_ARM8}" &&
#    make build_generated &&
#    make libcrypto.a &&
#    make install
#fi

# Boost Settings
BOOST_VERSION=1_58_0
BOOST_VERSION_DOT=1.58.0
BOOST_HASH=fdfc204fc33ec79c99b9a74944c3e54bd78be4f7f15e260c0e2700a36dc7d3e5
BOOST_SRC_DIR_ARM8="${SRC_DIR}/arm8"
BOOST_INSTALL_DIR_ARM8="${INSTALL_DIR}/arm8/boost_${BOOST_VERSION}"

export BOOST_VERSION BOOST_VERSION_DOT BOOST_HASH  BOOST_SRC_DIR_ARM8 BOOST_INSTALL_DIR_ARM8


if [ ! -f "$SRC_DIR/boost_${BOOST_VERSION}-raw.tar.bz2" ]; then
  cd "${SRC_DIR}" &&
    curl -s -L -o "boost_${BOOST_VERSION}-raw.tar.bz2" "https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2" &&
    echo "${BOOST_HASH}  boost_${BOOST_VERSION}-raw.tar.bz2" | sha256sum -c
fi

if [ ! -d "$BOOST_INSTALL_DIR_ARM8" ] && [ -f "$SRC_DIR/boost_${BOOST_VERSION}-raw.tar.bz2" ]; then

   mkdir -p "${BOOST_SRC_DIR_ARM8}" && cd "${BOOST_SRC_DIR_ARM8}" && tar -xf "${SRC_DIR}/boost_${BOOST_VERSION}-raw.tar.bz2"

fi

if [ ! -d "${BOOST_INSTALL_DIR_ARM8}" ] && [ -d "${BOOST_SRC_DIR_ARM8}/boost_${BOOST_VERSION}" ]; then

cd "${BOOST_SRC_DIR_ARM8}/boost_${BOOST_VERSION}" || exit

./bootstrap.sh --prefix="${BOOST_INSTALL_DIR_ARM8}" &&
./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

fi

