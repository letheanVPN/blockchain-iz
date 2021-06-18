FROM lthn/build:lthn-chain-linux as builder

WORKDIR /home/lthn/src/chain

COPY . .
# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static
ARG BUILD_THREADS=1
RUN rm -rf build && make -j${BUILD_THREADS} ${RELEASE_TYPE}

# Build stage over, now we make the end image.
FROM lthn/build:base-ubuntu-20-04 as final

ENV BASE_DIR="/home/lthn"
ENV IMG_TAG="chain"
ENV WALLET_DIR="${BASE_DIR}/wallet/${IMG_TAG}"
ENV BIN_DIR="${BASE_DIR}/bin/${IMG_TAG}"
ENV CONF_DIR="${BASE_DIR}/config/${IMG_TAG}"
ENV LOG_DIR="${BASE_DIR}/log/${IMG_TAG}"
ENV SRC_DIR="${BASE_DIR}/src/${IMG_TAG}"
ENV DATA_DIR="${BASE_DIR}/data/${IMG_TAG}"

# a copy of the binaries for extraction.
WORKDIR $BASE_DIR

# Create lethean user
RUN adduser --system --no-create-home --group --disabled-password lthn && \
	mkdir -p $DATA_DIR/lmdb $WALLET_DIR $LOG_DIR $BIN_DIR $CONF_DIR && \
	chown -R lthn:lthn $BASE_DIR ; \
    echo "lthn ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers;

COPY --from=builder --chown=lthn:lthn $SRC_DIR/utils/docker/home-dir $BASE_DIR
# grab the files made in the builder stage
#COPY --from=lthn/chain $BIN_DIR $BIN_DIR
COPY --from=builder --chown=lthn:lthn $SRC_DIR/build/release/bin $BIN_DIR


RUN chmod +x $BASE_DIR/lethean-blockchain.sh $BIN_DIR/*
# ports needed when running this image
EXPOSE 48782
EXPOSE 48772

# switch to lethean
USER lthn

ENTRYPOINT ["./lethean-blockchain.sh", "daemon"]


