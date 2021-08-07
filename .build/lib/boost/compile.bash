#!/bin/bash

if [ ! -d "${BOOST_INSTALL_DIR}" ] && [ -d "${BOOST_SRC_DIR}" ]; then

  echo "Compiling LibBoost 1.58 to: ${BOOST_INSTALL_DIR}"

  cd "${BOOST_SRC_DIR}" || exit

  # If OS is MacOS
  if [ -x "$(command -v sw_vers)" ]; then
    set -ex &&
    ./bootstrap.sh --with-toolset=gcc --prefix="${BOOST_INSTALL_DIR}" &&
    ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

  # If OS is Linux
  elif [ -x "$(command -v lsb_release)" ]; then
    set -ex &&
      ./bootstrap.sh --prefix="${BOOST_INSTALL_DIR}" &&
      ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

  # If OS is Windows
  elif [ -x "$(command -v uname)" ]; then
    ./bootstrap.sh --prefix="${BOOST_INSTALL_DIR}"
    ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

  fi

fi
