#!/bin/bash

if [ ! -f "$SRC_DIR/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
  cd "${SRC_DIR}" &&
  curl -s -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" &&
    echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c
fi

if [ ! -d "$OPENSSL_INSTALL_DIR_AMD64" ] && [ -f "$SRC_DIR/openssl-${OPENSSL_VERSION}.tar.gz" ]; then

  mkdir -p "${OPENSSL_SRC_DIR_AMD64}" &&  cd "${OPENSSL_SRC_DIR_AMD64}" && tar -xzf "${SRC_DIR}/openssl-${OPENSSL_VERSION}.tar.gz"

fi

if [ ! -d "$BOOST_INSTALL_DIR_ARM8" ] && [ -f "$SRC_DIR/openssl-${OPENSSL_VERSION}.tar.gz" ]; then

  mkdir -p "${OPENSSL_SRC_DIR_ARM8}" && cd "${OPENSSL_SRC_DIR_ARM8}" && tar -xzf "${SRC_DIR}/openssl-${OPENSSL_VERSION}.tar.gz"

fi
