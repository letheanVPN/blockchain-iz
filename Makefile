# Copyright (c) 2014-2017, The Monero Project
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of
#    conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list
#    of conditions and the following disclaimer in the documentation and/or other
#    materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be
#    used to endorse or promote products derived from this software without specific
#    prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
# EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
# THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
# THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

.ONESHELL:
all: setup
	bash build.bash

cmake-debug:
	mkdir -p build/debug
	cd build/debug && cmake -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=Debug ../..

debug: cmake-debug
	cd build/debug && $(MAKE)

debug-test:
	mkdir -p build/debug-test
	cd build/debug-test && cmake -D BUILD_TESTS=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=Debug ../.. && $(MAKE) && $(MAKE) test

debug-all:
	mkdir -p build/debug
	cd build/debug && cmake -D BUILD_TESTS=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Debug ../.. && $(MAKE)

debug-static-all:
	mkdir -p build/debug-static-all
	cd build/debug-static-all && cmake -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D BUILD_TESTS=ON -D STATIC=ON -D CMAKE_BUILD_TYPE=Debug ../.. && $(MAKE)

cmake-release:
	mkdir -p build/release
	cd build/release && cmake -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=Release ../..

release: cmake-release
	cd build/release && $(MAKE)

release-test:
	mkdir -p build/release-test
	cd build/release-test && cmake -D BUILD_TESTS=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=release ../.. && $(MAKE) && $(MAKE) test

release-all: clean
	echo "Making as many targets as your host will allow"
	rm -rf build/release-static-*
	make release-static-linux-x86_64
	echo "Taking a quick Nap to give the CPU a quick rest"
	sleep 9
	make release-static-freebsd-x86_64
	echo "Taking a quick Nap to give the CPU a quick rest"
	sleep 9
	make release-static-macos-x86_64


.ONESHELL:
release-static: clean
	mkdir -p build/release-static
	cd build/release-static
	cmake -D BUILD_TESTS=OFF -D STATIC=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=release ../.. && $(MAKE)


coverage:
	mkdir -p build/coverage
	cd build/coverage && cmake -D BUILD_TESTS=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=Debug -D COVERAGE=ON ../.. && $(MAKE) && $(MAKE) test

# Targets for specific prebuilt builds which will be advertised for updates by their build tag

release-static-linux-armv7:
	mkdir -p build/release-static-linux-armv7 build/release
	cd build/release-static-linux-armv7 && cmake -D BUILD_TESTS=OFF -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-armv7" ../.. && $(MAKE)

.ONESHELL:
release-static-rasbian-armv8:
	mkdir -p build/release-static-rasbian-armv8 build/release
	(cd build/release-static-rasbian-armv8 && cmake -D BUILD_TESTS=OFF -D ARCH="armv8-a" -DBOOST_ROOT=build/libs/arm8/boost_1_58_0 -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-armv8" ../.. && $(MAKE) )
	(cd build/release-static-rasbian-armv8/bin; tar -cvMaf ../../release/rasbian-armv8.tar.gz *)
	(cp -rf build/release-static-rasbian-armv8/bin build/release)


#release-static-linux-armv8:
#	mkdir -p build/release-static-linux-armv8
#	export CC=aarch64-linux-gnu-gcc
#	export CXX=aarch64-linux-gnu-g++
#	export ARCH=aarch64
#	cd build/release-static-linux-armv8 && cmake -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -DBOOST_ROOT=build/libs/arm8/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/arm8/openssl-1.1.0h -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-armv8" ../.. && $(MAKE)

.ONESHELL:
release-static-linux-x86_64:
	mkdir -p build/release-static-linux-x86_64 build/release
	(cd build/release-static-linux-x86_64 && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-x64" ../.. && $(MAKE) )
	(cd build/release-static-linux-x86_64/bin; tar -cvMaf ../../release/linux-x86_64.tar.gz *)
	(cp -rf build/release-static-linux-x86_64/bin build/release)

.ONESHELL:
release-static-freebsd-x86_64:
	mkdir -p build/release-static-freebsd-x86_64 build/release
	(cd build/release-static-freebsd-x86_64 && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="freebsd-x64" ../.. && $(MAKE) )
	(cd build/release-static-freebsd-x86_64/bin; tar -cvMaf ../../release/freebsd-x86_64.tar.gz *)
	cp -rf build/release-static-freebsd-x86_64/bin build/release

.ONESHELL:
release-static-macos-x86_64:
	mkdir -p build/release-static-macos-x86_64 build/release
	(cd build/release-static-macos-x86_64 && cmake -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="mac-x64" ../.. && $(MAKE) )
	(cd build/release-static-macos-x86_64/bin; tar -cvMaf ../../release/macos-x86_64.tar.gz *)
	cp -rf build/release-static-macos-x86_64/bin build/release

release-static-mac-arm64:
	mkdir -p build/release-static-mac-arm64
	cd build/release-static-mac-arm64 && cmake -D STATIC=ON -D ARCH="arm64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="macos-arm64" ../.. && $(MAKE)

release-static-win64:
	mkdir -p build/release-static-win64
	cd build/release-static-win64 && cmake -G "MSYS Makefiles" -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -DBOOST_ROOT=build/libs/x86_64/boost_1_58_0 -DOPENSSL_ROOT_DIR=build/libs/x86_64/openssl-1.1.0h -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=../../cmake/64-bit-toolchain.cmake -D MSYS2_FOLDER=c:/msys64 ../.. && $(MAKE)


fuzz:
	mkdir -p build/fuzz
	cd build/fuzz && cmake -D BUILD_TESTS=ON -D USE_LTO=OFF -D CMAKE_C_COMPILER=afl-gcc -D CMAKE_CXX_COMPILER=afl-g++ -D ARCH="x86-64" -D CMAKE_BUILD_TYPE=fuzz -D BUILD_TAG="linux-x64" ../.. && $(MAKE)

clean:
	echo rm -rf build/libs/src

tags:
	ctags -R --sort=1 --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ src contrib tests/gtest

.PHONY: all cmake-debug debug debug-test debug-all cmake-release release release-test release-all clean tags


.PHONY: setup
setup:
	chmod +x build.bash
