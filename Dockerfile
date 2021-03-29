# Uses a pre configured ubuntu:16.04 image
FROM registry.gitlab.com/lethean.io/devops:latest as builder

# Where all the works done.
WORKDIR /src

# pull in from build context
COPY . .

# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static

# if you want to clear build, purge the runner cache/prune the builder
RUN set -ex \
    && rm -rf build \
    && make ${RELEASE_TYPE}

# New image, changes output image to a fresh Ubuntu image.
FROM ubuntu:16.04

# grab the files made in the builder stage
COPY --from=builder /src/build/release/bin /usr/local/bin/

# clean up this new ubuntu
RUN set -ex && \
    apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt

# Create lethean user
RUN adduser --system --group --disabled-password lethean && \
	mkdir -p /wallet /home/lethean/.lethean && \
	chown -R lethean:lethean /home/lethean/.lethean && \
	chown -R lethean:lethean /wallet

# Contains the blockchain
VOLUME /home/lethean/.lethean

# Generate your wallet via accessing the container and run:
# cd /wallet
# lethean-wallet-cli
VOLUME /wallet

# ports needed when running this image
EXPOSE 48782
EXPOSE 48772

# switch to lethean
USER letheand

ENTRYPOINT ["letheand", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=48772", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=48782", "--non-interactive", "--confirm-external-bind"]

