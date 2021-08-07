#!/bin/bash

if [ ! -f "$SRC_DIR/openssl-${OPENSSL_VERSION}.tar.gz" ]; then
  cd "${SRC_DIR}" &&
  curl -s -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" &&
    echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c
fi

if [ ! -d "$OPENSSL_INSTALL_DIR" ] && [ -f "$SRC_DIR/openssl-${OPENSSL_VERSION}.tar.gz" ]; then

  mkdir -p "${OPENSSL_SRC_DIR}" &&  cd "${OPENSSL_SRC_DIR}" && tar -xzf "${SRC_DIR}/openssl-${OPENSSL_VERSION}.tar.gz"

fi

