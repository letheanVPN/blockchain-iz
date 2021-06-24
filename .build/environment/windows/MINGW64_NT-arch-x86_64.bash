#!/bin/bash

echo "We are now going to try and compile the libs we need on your machine"
echo "If this fails please report to our discord using the Website chat button"
echo "https://discord.lt.hn Please include the last error here, thank you, lets Compile!"
#sleep 9
# base settings
BASE_DIR=$(pwd)
SRC_DIR="$(pwd)/build/libs/src"
INSTALL_DIR="$(pwd)/build/libs"
export BASE_DIR=$BASE_DIR
export SRC_DIR=$SRC_DIR
export INSTALL_DIR=$INSTALL_DIR

mkdir -p "${SRC_DIR}"

# OpenSSL Settings
OPENSSL_VERSION=1.1.0h
OPENSSL_HASH=5835626cde9e99656585fc7aaa2302a73a7e1340bf8c14fd635a62c66802a517
OPENSSL_SRC_DIR="${SRC_DIR}/openssl-${OPENSSL_VERSION}"
OPENSSL_INSTALL_DIR="${INSTALL_DIR}/openssl-${OPENSSL_VERSION}"

export OPENSSL_VERSION=$OPENSSL_VERSION
export OPENSSL_HASH=$OPENSSL_HASH
export OPENSSL_SRC_DIR=$OPENSSL_SRC_DIR
export OPENSSL_INSTALL_DIR=$OPENSSL_INSTALL_DIR

bash .build/lib/openssl/download.bash
bash .build/lib/openssl/compile.bash

export OPENSSL_LIBRARY="$OPENSSL_INSTALL_DIR/lib"
export OPENSSL_INCLUDE_DIR="$OPENSSL_INSTALL_DIR/include"
export OPENSSL_ROOT_DIR="$OPENSSL_INSTALL_DIR"
# Boost Settings
BOOST_VERSION=1_58_0
BOOST_VERSION_DOT=1.58.0
BOOST_HASH=fdfc204fc33ec79c99b9a74944c3e54bd78be4f7f15e260c0e2700a36dc7d3e5
BOOST_SRC_DIR="${SRC_DIR}/boost_${BOOST_VERSION}"
BOOST_INSTALL_DIR="${INSTALL_DIR}/boost_${BOOST_VERSION}"

export BOOST_VERSION=$BOOST_VERSION
export BOOST_VERSION_DOT=$BOOST_VERSION_DOT
export BOOST_HASH=$BOOST_HASH
export BOOST_SRC_DIR=$BOOST_SRC_DIR
export BOOST_INSTALL_DIR=$BOOST_INSTALL_DIR

bash .build/lib/boost/download.bash

bash .build/lib/boost/compile.bash

export BOOST_ROOT="$BOOST_INSTALL_DIR"

if [ -d "${BASE_DIR}/.build/libs/windows-x86_64" ]; then

  echo "Cleaning up and putting a copy in ${BASE_DIR}/.build/libs/"
  rm -rf "${SRC_DIR}"

  if [ ! -d "${BASE_DIR}/.build/libs/windows-x86_64" ]; then
    mkdir -p "${BASE_DIR}/.build/libs/windows-x86_64"
    cp -rf "${INSTALL_DIR}/" "${BASE_DIR}/.build/libs/windows-x86_64"

  fi

  sleep 9
fi
export DEVELOPER_LOCAL_TOOLS=1


