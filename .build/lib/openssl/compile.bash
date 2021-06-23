#!/bin/bash

if [ ! -d "${OPENSSL_INSTALL_DIR}" ] && [ -d "${OPENSSL_SRC_DIR}" ]; then

  echo "Found OpenSSL source folder, compiling to: ${OPENSSL_INSTALL_DIR}."
  sleep 6

  set -x &&
    cd "${OPENSSL_SRC_DIR}" &&
    ./Configure linux-x86_64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install

fi
