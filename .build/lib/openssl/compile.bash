#!/usr/bin/env bash

if [ -d "${OPENSSL_SRC_DIR}" ]; then

  echo "Found OpenSSL source folder, compiling to: ${OPENSSL_INSTALL_DIR}."
  sleep 6

  set -x &&
    cd "${OPENSSL_SRC_DIR}" &&
    ./Configure linux-x86_64 no-shared --static -fPIC --openssldir="${OPENSSL_INSTALL_DIR}" --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install

    rm -rf "${OPENSSL_INSTALL_DIR:?}/bin"
    rm -rf "${OPENSSL_INSTALL_DIR:?}/certs"
    rm -rf "${OPENSSL_INSTALL_DIR:?}/misc"
    rm -rf "${OPENSSL_INSTALL_DIR:?}/private"
    rm -rf "${OPENSSL_INSTALL_DIR:?}/share"
    rm -rf "${OPENSSL_INSTALL_DIR:?}/openssl.cn*"
fi