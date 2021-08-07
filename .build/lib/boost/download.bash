#!/bin/bash

if [ ! -d "${BOOST_INSTALL_DIR}" ] && [ ! -d "${BOOST_SRC_DIR}" ]; then

  echo "LibBoost Source not found, downloading to: ${BOOST_SRC_DIR}"


    cd "${SRC_DIR}" &&
    curl -s -L -o "boost_${BOOST_VERSION}-raw.tar.bz2" https://downloads.sourceforge.net/project/boost/boost/${BOOST_VERSION_DOT}/boost_${BOOST_VERSION}.tar.bz2 &&
    echo "${BOOST_HASH}  boost_${BOOST_VERSION}-raw.tar.bz2" | sha256sum -c &&
    echo "Extracting to build/libs/src/boost_1_58_0" &&
    tar -xf "boost_${BOOST_VERSION}-raw.tar.bz2"

fi
