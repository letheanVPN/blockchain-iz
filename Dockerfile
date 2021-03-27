FROM ubuntu:14.04

ENV SRC_DIR /usr/local/src/lethean

WORKDIR /usr/local

RUN set -x \
  && buildDeps=' \
      g++ curl make pkg-config libssl-dev libzmq3-dev  \
      libsodium-dev libunwind8-dev liblzma-dev libreadline6-dev libldns-dev libexpat1-dev doxygen \
      graphviz libpgm-dev \
  ' \
  && apt-get -qq update \
  && apt-get -qq --no-install-recommends install $buildDeps

#Cmake
ARG CMAKE_VERSION=3.12.1
ARG CMAKE_VERSION_DOT=v3.12
ARG CMAKE_HASH=c53d5c2ce81d7a957ee83e3e635c8cda5dfe20c9d501a4828ee28e1615e57ab2
RUN set -ex \
    && curl -s -O https://cmake.org/files/${CMAKE_VERSION_DOT}/cmake-${CMAKE_VERSION}.tar.gz \
    && echo "${CMAKE_HASH}  cmake-${CMAKE_VERSION}.tar.gz" | sha256sum -c \
    && tar -xzf cmake-${CMAKE_VERSION}.tar.gz \
    && cd cmake-${CMAKE_VERSION} \
    && ./configure \
    && make \
    && make install


### Boost
ARG BOOST_VERSION=1_68_0
ARG BOOST_VERSION_DOT=1.68.0
ARG BOOST_HASH=7f6130bc3cf65f56a618888ce9d5ea704fa10b462be126ad053e80e553d6d8b7
RUN set -ex \
    && curl -s -L -o  boost_${BOOST_VERSION}.tar.bz2 https://dl.bintray.com/boostorg/release/${BOOST_VERSION_DOT}/source/boost_${BOOST_VERSION}.tar.bz2 \
    && echo "${BOOST_HASH}  boost_${BOOST_VERSION}.tar.bz2" | sha256sum -c \
    && tar -xvf boost_${BOOST_VERSION}.tar.bz2 \
    && cd boost_${BOOST_VERSION} \
    && ./bootstrap.sh \
    && ./b2 --build-type=minimal link=static runtime-link=static --with-chrono --with-date_time --with-filesystem --with-program_options --with-regex --with-serialization --with-system --with-thread --with-locale threading=multi threadapi=pthread cflags="-fPIC" cxxflags="-fPIC" install
ENV BOOST_ROOT /usr/local/boost_${BOOST_VERSION}

#RUN git clone https://gitlab.com/lethean.io/blockchain/lethean.git $SRC_DIR
WORKDIR $SRC_DIR
COPY . .

ENV USE_SINGLE_BUILDDIR=1
RUN rm -rf build
RUN make release-static

RUN cp build/release/bin/* /usr/local/bin/ \
  \
  && rm -r $SRC_DIR \
  && apt-get -qq --auto-remove purge $buildDeps

# Contains the blockchain
VOLUME /root/.lethean

# Generate your wallet via accessing the container and run:
# cd /wallet
# lethean-wallet-cli
VOLUME /wallet

ENV LOG_LEVEL 0
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 48772
ENV RPC_BIND_IP 127.0.0.1
ENV RPC_BIND_PORT 48782

EXPOSE 48782
EXPOSE 48772

CMD letheand --log-level=$LOG_LEVEL --p2p-bind-ip=$P2P_BIND_IP --p2p-bind-port=$P2P_BIND_PORT --rpc-bind-ip=$RPC_BIND_IP --rpc-bind-port=$RPC_BIND_PORT
