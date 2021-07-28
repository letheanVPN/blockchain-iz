FROM lthn/build:lthn-chain-linux as builder

ARG BASE_DIR="/home/lthn"
ARG IMG_TAG="chain"
ARG BIN_DIR="${BASE_DIR}/bin/${IMG_TAG}"
ARG SRC_DIR="${BASE_DIR}/src/${IMG_TAG}"
ARG COMPILE=0
ARG RELEASE_TYPE=release-static-linux-x86_64
# this is only in the build layers,
WORKDIR $SRC_DIR
COPY --from=lthn/chain $BIN_DIR $SRC_DIR/build/release/bin

COPY . ${SRC_DIR}

RUN if [ "${COMPILE}" = 1 ] ; then cd $SRC_DIR && rm -rf build && make ${RELEASE_TYPE} ; else echo "using precompile from lthn/chain"; fi

FROM ubuntu:20.04 as final

ARG BASE_DIR="/home/lthn"
ARG IMG_TAG="chain"
ARG BIN_DIR="${BASE_DIR}/bin/${IMG_TAG}"
ARG SRC_DIR="${BASE_DIR}/src/${IMG_TAG}"

ENV BIN_DIR="${BIN_DIR}"

ENV WALLET_DIR="${BASE_DIR}/wallet/${IMG_TAG}"

ENV CONF_DIR="${BASE_DIR}/config/${IMG_TAG}"
ENV LOG_DIR="${BASE_DIR}/log/${IMG_TAG}"

ENV DATA_DIR="${BASE_DIR}/data/${IMG_TAG}"
RUN adduser lthn --disabled-password

COPY --from=builder --chown=lthn:lthn $SRC_DIR/utils/docker/home-dir $BASE_DIR
COPY --from=builder --chown=lthn:lthn $SRC_DIR/build/release/bin $BIN_DIR
RUN chmod +x $BASE_DIR/lethean-blockchain.sh $BIN_DIR/*
# a copy of the binaries for extraction.
WORKDIR $BASE_DIR

EXPOSE 48782
EXPOSE 48772


CMD ["docker"]
ENTRYPOINT ["./lethean-blockchain.sh"]


