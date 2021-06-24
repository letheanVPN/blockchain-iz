#!/bin/bash

if [ ! -d "${OPENSSL_INSTALL_DIR}" ] && [ -d "${OPENSSL_SRC_DIR}" ]; then

  echo "Found OpenSSL source folder, compiling to: ${OPENSSL_INSTALL_DIR}."
    # If OS is MacOS
  if [ -x "$(command -v sw_vers)" ]; then
    set -x &&
    cd "${OPENSSL_SRC_DIR}" &&
    ./Configure linux-x86_64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install

  # If OS is Linux
  elif [ -x "$(command -v lsb_release)" ]; then
    set -x &&
    cd "${OPENSSL_SRC_DIR}" &&
    ./Configure linux-x86_64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install

  # If OS is Windows
  elif [ -x "$(command -v uname)" ]; then
    set -x &&
    cd "${OPENSSL_SRC_DIR}" &&
    ./Configure mingw64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install
  fi

fi
