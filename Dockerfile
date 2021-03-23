FROM ubuntu:16.04

ENV SRC_DIR /usr/local/src/lethean

RUN set -x \
  && buildDeps=' \
      ca-certificates \
      cmake \
      libunbound-dev \
      libminiupnpc-dev \
      libunwind8-dev \
      liblzma-dev \
      libldns-dev \
      libexpat1-dev \
      build-essential \
      libreadline-dev \
      gcc-4.8 \
      git \
      libboost-all-dev \
      libssl-dev \
      make \
      pkg-config \
  ' \
  && apt-get -qq update \
  && apt-get -qq --no-install-recommends install $buildDeps

RUN git clone --recurse-submodules https://gitlab.com/lethean.io/blockchain/lethean.git $SRC_DIR
WORKDIR $SRC_DIR

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
