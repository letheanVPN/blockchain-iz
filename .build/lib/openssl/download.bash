#!/bin/bash

if [ ! -d "${OPENSSL_INSTALL_DIR}" ] && [ ! -d "${OPENSSL_SRC_DIR}" ]; then

  echo "OpenSSL Source not found, downloading to: ${OPENSSL_SRC_DIR}."
  sleep 3

  mkdir -p "${OPENSSL_SRC_DIR}"

  set -x &&
    cd "${SRC_DIR}" &&
    curl -s -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" &&
    echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c &&
    tar -xzf "openssl-${OPENSSL_VERSION}.tar.gz"

fi