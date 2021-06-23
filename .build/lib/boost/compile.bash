#!/usr/bin/env bash

if [ -d "${BOOST_SRC_DIR}" ]; then

  echo "Compiling LibBoost 1.58 to: ${BOOST_INSTALL_DIR}"
  sleep 6


  cd "${BOOST_SRC_DIR}" || exit

  set -x &&
    ./bootstrap.sh --prefix="${BOOST_INSTALL_DIR}" &&
    ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

fi