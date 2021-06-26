#!/bin/bash

if [ ! -d "${BOOST_INSTALL_DIR_AMD64}" ] && [ -d "${BOOST_SRC_DIR_AMD64}" ]; then

  echo "Compiling LibBoost 1.58 to: ${BOOST_INSTALL_DIR_AMD64}"

  cd "${BOOST_SRC_DIR_AMD64}/boost_${BOOST_VERSION}" || exit

  set -ex &&
    ./bootstrap.sh --prefix="${BOOST_INSTALL_DIR_AMD64}" &&
    ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

#  # If OS is Windows
#  elif [ -x "$(command -v uname)" ]; then
#    ./bootstrap.sh --prefix="${BOOST_INSTALL_DIR}"
#    ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install
#
#  fi

fi

if [ ! -d "${BOOST_INSTALL_DIR_ARM8}" ] && [ -d "${BOOST_SRC_DIR_ARM8}/boost_${BOOST_VERSION}" ]; then

  echo "Compiling LibBoost 1.58 to: ${BOOST_INSTALL_DIR}"

  cd "${BOOST_SRC_DIR_ARM8}/icu/"
  sh "${BOOST_SRC_DIR_ARM8}/icu/icu/source/runConfigureICU" Linux/gcc
  sh "${BOOST_SRC_DIR_ARM8}"/icu/icu/configure --disable-samples --disable-tests --with-cross-build="${BOOST_SRC_DIR_ARM8}/icu" --prefix="${BOOST_INSTALL_DIR_ARM8}"/icu \
              --host=arm-himix200-linux
  make -j
  make install

  cd "${BOOST_SRC_DIR_ARM8}/boost_${BOOST_VERSION}" || exit

  set -ex &&
    echo "using gcc : arm : aarch64-linux-gnu-gcc ;" >user-config.jam &&
    ./bootstrap.sh toolset=gcc-arm architecture=arm abi=aapcs address-model=64 --prefix="${BOOST_INSTALL_DIR_ARM8}" &&
    ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem \
      --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale \
      --user-config=./user-config.jam \
      threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install

fi

exit 2
