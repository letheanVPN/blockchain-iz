#!/usr/bin/env bash

if [ ! -d "$OPENSSL_INSTALL_DIR" ] && [ -d "$OPENSSL_SRC_DIR/openssl-${OPENSSL_VERSION}" ]; then

  echo "Compiling OpenSSL for x86_64: ${OPENSSL_SRC_DIR}/openssl-${OPENSSL_VERSION}."
    # If OS is MacOS
  if [ -x "$(command -v sw_vers)" ]; then
        # shellcheck disable=SC2154
#    if [ "$archType" = "arm64" ]; then
#      echo "Applying patch to OpenSSL to Compile on $archType"
#      bash .build/lib/openssl/patches/macos-arm64.bash
#    fi
    set -x &&
    cd "$OPENSSL_SRC_DIR/openssl-${OPENSSL_VERSION}" &&
    ./Configure darwin64-x86_64-cc no-asm no-shared -fPIC --prefix="${OPENSSL_INSTALL_DIR}" --openssldir="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install

  # If OS is Linux
  elif [ -x "$(command -v lsb_release)" ]; then
    set -x &&
    cd "$OPENSSL_SRC_DIR/openssl-${OPENSSL_VERSION}" &&
    ./Configure linux-x86_64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install

  # If OS is Windows
  elif [ -x "$(command -v uname)" ]; then
    set -x &&
    cd "$OPENSSL_SRC_DIR/openssl-${OPENSSL_VERSION}" &&
    ./Configure mingw64 no-shared --static -fPIC --prefix="${OPENSSL_INSTALL_DIR}" &&
    make build_generated &&
    make libcrypto.a &&
    make install
  fi

fi



