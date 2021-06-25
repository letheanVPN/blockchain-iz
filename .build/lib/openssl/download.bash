#!/bin/bash

if [ ! -d "${OPENSSL_INSTALL_DIR}" ] && [ ! -d "${OPENSSL_SRC_DIR}" ]; then

  printf "Local OpenSSL not found, downloading source code:"
  echo "${OPENSSL_SRC_DIR}"

  mkdir -p "${OPENSSL_SRC_DIR}"

  cd "${SRC_DIR}" &&
    curl -s -O "https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz" &&
    echo "${OPENSSL_HASH}  openssl-${OPENSSL_VERSION}.tar.gz" | sha256sum -c &&
    printf "\n\nThis next bit takes time, even with a good machine, but it will get cached for future\n\n"
    tar -xzf "openssl-${OPENSSL_VERSION}.tar.gz"

fi
