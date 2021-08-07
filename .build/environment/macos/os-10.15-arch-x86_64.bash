#!/usr/bin/env bash

printf "We are now going to try and compile the libs we need on your machine\n"
printf "If this fails please report to our discord using the Website chat button\n"
printf "https://discord.lt.hn Please include the last error here, thank you, lets Compile!\n\n\n"

# base settings
BASE_DIR=$(pwd)
SRC_DIR="$(pwd)/build/libs/src"
INSTALL_DIR="$(pwd)/build/libs"
export BASE_DIR=$BASE_DIR
export SRC_DIR=$SRC_DIR
export INSTALL_DIR=$INSTALL_DIR


brew update && brew bundle cleanup --file="$BASE_DIR/.build/environment/macos/Brewfile"


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

export BOOST_VERSION BOOST_VERSION_DOT BOOST_HASH BOOST_SRC_DIR BOOST_INSTALL_DIR

bash .build/lib/boost/download.bash
bash .build/lib/boost/compile.bash

