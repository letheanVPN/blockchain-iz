#!/bin/bash

if [ ! -f "$SRC_DIR/boost_${BOOST_VERSION}-raw.tar.bz2" ]; then
  cd "${SRC_DIR}" &&
    curl -s -L -o "boost_${BOOST_VERSION}-raw.tar.bz2" "https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2" &&
    echo "${BOOST_HASH}  boost_${BOOST_VERSION}-raw.tar.bz2" | sha256sum -c
fi

if [ ! -d "$BOOST_INSTALL_DIR_AMD64" ] && [ -f "$SRC_DIR/boost_${BOOST_VERSION}-raw.tar.bz2" ]; then

  mkdir -p "${BOOST_SRC_DIR_AMD64}" && cd "${BOOST_SRC_DIR_AMD64}" && tar -xf "${SRC_DIR}/boost_${BOOST_VERSION}-raw.tar.bz2"

fi

if [ ! -d "$BOOST_INSTALL_DIR_ARM8" ] && [ -f "$SRC_DIR/boost_${BOOST_VERSION}-raw.tar.bz2" ]; then

  (cd "${SRC_DIR}" && curl -s -L -o icu4c-69_1-src.tgz https://github.com/unicode-org/icu/releases/download/release-69-1/icu4c-69_1-src.tgz)

  mkdir -p "${BOOST_SRC_DIR_ARM8}/icu" && cd "${BOOST_SRC_DIR_ARM8}/icu" && tar -xzf "${SRC_DIR}/icu4c-69_1-src.tgz"
  mkdir -p "${BOOST_SRC_DIR_ARM8}" && cd "${BOOST_SRC_DIR_ARM8}" && tar -xf "${SRC_DIR}/boost_${BOOST_VERSION}-raw.tar.bz2"

fi
