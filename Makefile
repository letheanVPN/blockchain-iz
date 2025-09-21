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

# Provide current version here instead of versin.h.in file
LETHEAN_VERSION?=5.0.4
LETHEAN_RELEASE?=linux
LETHEAN_CMAKE_FLAGS?=""

all: help

cmake-debug:
	mkdir -p build/$(LETHEAN_VERSION)/debug
	cd build/$(LETHEAN_VERSION)/debug && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D CMAKE_BUILD_TYPE=Debug ../../..

debug: cmake-debug
	cd build/$(LETHEAN_VERSION)/debug && $(MAKE)

debug-test:
	mkdir -p build/$(LETHEAN_VERSION)/debug
	cd build/$(LETHEAN_VERSION)/debug && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=ON -D CMAKE_BUILD_TYPE=Debug ../../.. && $(MAKE) && $(MAKE) test

debug-all:
	mkdir -p build/$(LETHEAN_VERSION)/debug
	cd build/$(LETHEAN_VERSION)/debug && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=ON -D BUILD_SHARED_LIBS=OFF -D CMAKE_BUILD_TYPE=Debug ../../.. && $(MAKE)

debug-static-all:
	mkdir -p build/$(LETHEAN_VERSION)/debug
	cd build/$(LETHEAN_VERSION)/debug && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=ON -D STATIC=ON -D CMAKE_BUILD_TYPE=Debug ../../.. && $(MAKE)

cmake-release:
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D CMAKE_BUILD_TYPE=Release ../../..

release: cmake-release
	cd build/$(LETHEAN_VERSION)/release && $(MAKE)

release-test:
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=ON -D CMAKE_BUILD_TYPE=release ../../.. && $(MAKE) && $(MAKE) test

release-all:
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=ON -D CMAKE_BUILD_TYPE=release ../../.. && $(MAKE)

release-static: ## Linux 64 & Boost Compile
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release ../../.. && $(MAKE)

coverage:
	mkdir -p build/$(LETHEAN_VERSION)/debug
	cd build/$(LETHEAN_VERSION)/debug && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=ON -D CMAKE_BUILD_TYPE=Debug -D COVERAGE=ON ../../.. && $(MAKE) && $(MAKE) test

# Targets for specific prebuilt builds which will be advertised for updates by their build tag

ci-release: # cp & chmod release/bin/lethean*) & LICENCE > build/$LETHEAN_VERSION/packaged/
	rm build/$(LETHEAN_VERSION)/packaged/$(LETHEAN_RELEASE).zip || true
	chmod +x build/$(LETHEAN_VERSION)/release/bin/lethean*
	mkdir -p build/packaged
	cp build/$(LETHEAN_VERSION)/release/bin/* build/packaged/

zip-release: ci-release # cd into packaged, zip a clean release file for an artifact
	cp LICENSE build/packaged/LICENSE
	cd  build/packaged/ && tar -cvf ../$(LETHEAN_RELEASE).tar .


release-static-linux-armv6: ## arch: armv6zk
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=OFF -D ARCH="armv6zk" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-armv6" ../../.. && $(MAKE)

release-static-linux-armv7: ## arch: armv7-a
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=OFF -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-armv7" ../../.. && $(MAKE)

release-static-android: ## arch: armv7-a
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=OFF -D ARCH="armv7-a" -D STATIC=ON -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=release -D ANDROID=true -D INSTALL_VENDORED_LIBUNBOUND=ON -D BUILD_TAG="android" ../../.. && $(MAKE)

release-static-linux-armv8: ## arch: armv8-a
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D BUILD_TESTS=OFF -D ARCH="armv8-a" -D STATIC=ON -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-armv8" ../../.. && $(MAKE)

release-static-linux-x86_64: ## Linux 64
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-x64" ../../.. && $(MAKE)

release-static-linux-x86_64-boost:
	cd boost && ./bootstrap.sh && ./b2 --prefix=$(shell pwd)/deps --layout=system address-model=64 runtime-link=static link=static variant=release threading=multi --with-system --with-filesystem --with-thread --with-date_time --with-chrono --with-regex --with-serialization --with-program_options --with-atomic --with-locale install

release-static-linux-x86_64-local-boost: release-static-linux-x86_64-boost
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D Boost_NO_SYSTEM_PATHS=TRUE -D BOOST_ROOT=$(shell pwd)/deps -D CMAKE_BUILD_TYPE=release -D Boost_NO_BOOST_CMAKE=ON -D BUILD_TAG="linux-x64" ../../.. && $(MAKE)

release-static-freebsd-x86_64: ## FreeBSD 64
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="freebsd-x64" ../../.. && $(MAKE)

release-static-mac-x86_64: ## macOS64-intel
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="mac-x64" ../../.. && $(MAKE)

release-static-linux-i686: ## Linux32
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -D LETHEAN_VERSION=$(LETHEAN_VERSION)  -D STATIC=ON -D ARCH="i686" -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=release -D BUILD_TAG="linux-x86" ../../.. && $(MAKE)

release-static-win64: ## Windows64
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -G "MSYS Makefiles" -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="x86-64" -D BUILD_64=ON -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x64" -D CMAKE_TOOLCHAIN_FILE=../../../cmake/64-bit-toolchain.cmake $(LETHEAN_CMAKE_FLAGS) -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) ../../.. && $(MAKE)

release-static-win64-boost: ## Windows64 & Boost Compile
	cd boost && ./bootstrap.sh && ./b2 --prefix=$(shell cd ${MINGW_PREFIX} && pwd -W) --layout=system address-model=64 runtime-link=static link=static variant=release threading=multi --with-system --with-filesystem --with-thread --with-date_time --with-chrono --with-regex --with-serialization --with-program_options --with-atomic --with-locale install

release-static-win32: ## Windows32
	mkdir -p build/$(LETHEAN_VERSION)/release
	cd build/$(LETHEAN_VERSION)/release && cmake $(LETHEAN_CMAKE_FLAGS) -G "MSYS Makefiles" -D LETHEAN_VERSION=$(LETHEAN_VERSION) -D STATIC=ON -D ARCH="i686" -D BUILD_64=OFF -D CMAKE_BUILD_TYPE=Release -D BUILD_TAG="win-x32" -D CMAKE_TOOLCHAIN_FILE=../../../cmake/32-bit-toolchain.cmake $(LETHEAN_CMAKE_FLAGS) -D MSYS2_FOLDER=$(shell cd ${MINGW_PREFIX}/.. && pwd -W) ../../.. && $(MAKE)

docker-testnet: ## Run testnet Docker daemon
	docker run -it lthn/chain:testnet

fuzz:
	mkdir -p build/fuzz
	cd build/fuzz && cmake $(LETHEAN_CMAKE_FLAGS) -D BUILD_TESTS=ON -D USE_LTO=OFF -D CMAKE_C_COMPILER=afl-gcc -D CMAKE_CXX_COMPILER=afl-g++ -D ARCH="x86-64" -D CMAKE_BUILD_TYPE=fuzz -D BUILD_TAG="linux-x64" ../.. && $(MAKE)

clean: ## Deletes build/LETHEAN_VERSION & deps/
	@echo "WARNING: Back-up your wallet if it exists within ./build!" ; \
        read -r -p "This will destroy the v$(LETHEAN_VERSION) build directory, continue (y/N)?: " CONTINUE; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -rf build/$(LETHEAN_VERSION)
	rm -rf deps/

clean-all: ## Deletes build/* & deps/
	@echo "WARNING: Back-up your wallet if it exists within ./build!" ; \
        read -r -p "This will destroy the build directory, continue (y/N)?: " CONTINUE; \
	[ $$CONTINUE = "y" ] || [ $$CONTINUE = "Y" ] || (echo "Exiting."; exit 1;)
	rm -rf build/*
	rm -rf deps/

tags:
	ctags -R --sort=1 --c++-kinds=+p --fields=+iaS --extra=+q --language-force=C++ src contrib tests/gtest


help: ## Show this help
	@egrep -h '\s##\s' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m make %-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all cmake-debug debug debug-test debug-all cmake-release release release-test release-all clean tags ci-release-mac-x86_64
