FROM ubuntu:16.04 as build

ARG RELEASE_TYPE=release-static

RUN apt-get -qq update \
  && apt-get -qq --no-install-recommends install ca-certificates libboost-all-dev cmake g++ git libssl-dev make pkg-config libunbound-dev

WORKDIR /lethean
COPY . .

RUN make -j$(nproc) ${RELEASE_TYPE}

RUN make ci-release

FROM debian:11.8-slim as container

COPY --from=build /lethean/build/packaged/lethean* /usr/local/bin
RUN apt-get update && apt-get install -y ca-certificates

# Contains the blockchain
VOLUME /root/Lethean


# Generate your wallet via accessing the container and run:
# cd /wallet
# lethean-wallet-cli
VOLUME /wallet

ENV LOG_LEVEL 0



# P2P live + testnet
ENV P2P_BIND_IP 0.0.0.0
ENV P2P_BIND_PORT 48772
ENV TEST_P2P_BIND_PORT 38772

# RPC live + testnet
ENV RPC_BIND_IP 0.0.0.0
ENV RPC_BIND_PORT 48782
ENV TEST_RPC_BIND_PORT 38782
ENV DATA_DIR /root/Lethean/data
ENV TEST_DATA_DIR /root/Lethean/data/testnet

RUN mkdir -p ${TEST_DATA_DIR}

EXPOSE 48782
EXPOSE 48772
EXPOSE 38772
EXPOSE 38782

CMD letheand --non-interactive --confirm-external-bind --data-dir=$DATA_DIR --testnet-data-dir=$TEST_DATA_DIR --log-level=$LOG_LEVEL \
    --testnet-rpc-bind-port=$TEST_RPC_BIND_PORT --p2p-bind-ip=$P2P_BIND_IP --testnet-p2p-bind-port=$TEST_P2P_BIND_PORT --p2p-bind-port=$P2P_BIND_PORT --rpc-bind-ip=$RPC_BIND_IP --rpc-bind-port=$RPC_BIND_PORT

