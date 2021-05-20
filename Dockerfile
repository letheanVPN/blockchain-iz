# Building stage, Uses a pre configured ubuntu:16.04 image
FROM registry.gitlab.com/lthn.io/projects/sdk/build/latest as builder


WORKDIR /home/lthn/src/chain

COPY . .
# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static

#RUN rm -rf build && make ${RELEASE_TYPE}

# Build stage over, now we make the end image.
FROM ubuntu:16.04

ENV BASE_DIR="/home/lthn"
ENV IMG_TAG="chain"
ENV WALLET_DIR="${BASE_DIR}/wallet/${IMG_TAG}"
ENV BIN_DIR="${BASE_DIR}/bin/${IMG_TAG}"
ENV CONF_DIR="${BASE_DIR}/config/${IMG_TAG}"
ENV LOG_DIR="${BASE_DIR}/log/${IMG_TAG}"
ENV SRC_DIR="${BASE_DIR}/src/${IMG_TAG}"
ENV DATA_DIR="${BASE_DIR}/data/${IMG_TAG}"

# clean up this new ubuntu
RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates sudo libreadline6 && \
    apt-get clean && \
    rm -rf /var/lib/apt

# a copy of the binaries for extraction.
WORKDIR $BASE_DIR

# Create lethean user
RUN adduser --system --no-create-home --group --disabled-password lthn && \
	mkdir -p $DATA_DIR/lmdb $WALLET_DIR $LOG_DIR $BIN_DIR $CONF_DIR && \
	chown -R lthn:lthn $BASE_DIR ; \
    echo "lthn ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers;

COPY --from=builder $SRC_DIR/utils/docker/home-dir $BASE_DIR
# grab the files made in the builder stage
COPY --from=lthn/chain $BIN_DIR $BIN_DIR
#COPY --from=builder $SRC_DIR/build/release/bin $BIN_DIR


RUN chmod +x $BASE_DIR/docker-entrypoint.sh
# ports needed when running this image
EXPOSE 48782
EXPOSE 48772

# switch to lethean
USER lthn

ENTRYPOINT ["./docker-entrypoint.sh", "daemon"]


