FROM ubuntu:16.04 as build

ARG RELEASE_TYPE=release-static

RUN set -ex && \
    apt-get -qq update && \
    DEBIAN_FRONTEND=noninteractive apt-get -qq --no-install-recommends install ccache \
      ca-certificates libboost-all-dev cmake g++ git libssl-dev make pkg-config libunbound-dev

WORKDIR /lethean

