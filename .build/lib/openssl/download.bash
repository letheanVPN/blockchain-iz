#!/bin/bash

if [ ! -d "${OPENSSL_INSTALL_DIR}" ] && [ ! -d "${OPENSSL_SRC_DIR}" ]; then

  echo "OpenSSL Source not found, downloading to: ${OPENSSL_SRC_DIR}."

  mkdir -p "${OPENSSL_SRC_DIR}"


    cd "${SRC_DIR}" &&
    curl -s -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" &&
    echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c &&
    echo "This next bit takes time, even with a good machine, but it will get cached for future"
    tar -xvzf "openssl-${OPENSSL_VERSION}.tar.gz"

fi