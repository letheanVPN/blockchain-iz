# Uses a pre configured ubuntu:16.04 image - this file has a update in dev
FROM registry.gitlab.com/lethean.io/sdk/builder/latest as builder

# Where all the works done.
WORKDIR /usr/local/src/lethean.io/blockchain/lethean

COPY . .
# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE=release-static

# if you want to clear build, purge the runner cache/prune the builder
RUN rm -rf build && make ${RELEASE_TYPE}

# New image, changes output image to a fresh Ubuntu image.
FROM ubuntu:16.04

# grab the files made in the builder stage
COPY --from=builder /usr/local/src/lethean.io/blockchain/lethean/build/release/bin /usr/local/bin
COPY --from=builder /usr/local/src/lethean.io/blockchain/lethean/build/release/bin /home/leathean/bin

# clean up this new ubuntu
RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates libreadline6 && \
    apt-get clean && \
    rm -rf /var/lib/apt

# Create lethean user
RUN adduser --system --group --disabled-password lethean && \
	mkdir -p /wallet /home/lethean/.lethean /home/lethean/.intensecoin /home/lethean/bin && \
	chown -R lethean:lethean /home/lethean && \
	chown -R lethean:lethean /wallet

# a copy of the binaries for extraction.
VOLUME /home/lethean/bin

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
USER lethean

ENTRYPOINT ["letheand", "--p2p-bind-ip=0.0.0.0", "--p2p-bind-port=48772", "--rpc-bind-ip=0.0.0.0", "--rpc-bind-port=48782", "--non-interactive", "--confirm-external-bind"]

