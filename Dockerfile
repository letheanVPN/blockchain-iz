# Building stage, Uses a pre configured ubuntu:16.04 image
FROM registry.gitlab.com/lethean.io/devops/build:latest as builder

# Where all the works done.
WORKDIR /usr/local/src/lethean.io/blockchain/lethean

COPY . .
# make type to use, to change --build-arg RELEASE_TYPE=release-test
ARG RELEASE_TYPE

# if you want to clear build, purge the runner cache/prune the builder
#RUN rm -rf build && make ${RELEASE_TYPE}

# Build stage over, now we make the end image.
FROM ubuntu:16.04

# clean up this new ubuntu
RUN apt-get update && \
    apt-get --no-install-recommends --yes install ca-certificates sudo libreadline6 && \
    apt-get clean && \
    rm -rf /var/lib/apt

# a copy of the binaries for extraction.
WORKDIR /home/lthn

VOLUME /home/lthn

COPY --from=builder /usr/local/src/lethean.io/blockchain/lethean/utils/docker /home/lthn
# grab the files made in the builder stage
#COPY --from=builder /usr/local/src/lethean.io/blockchain/lethean/build/release/bin /home/lthn/bin
COPY --from=registry.gitlab.com/lethean.io/blockchain/lethean:latest /usr/local/bin /home/lthn/bin

# Create lethean user
RUN adduser --system --no-create-home --group --disabled-password lthn && \
	mkdir -p data/lmdb wallet /etc/lthn /var/log/lthn /var/run/lthn  && \
	chown -R lthn:lthn /home/lthn/ /etc/lthn /var/log/lthn ; \
    echo "lthn ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers;

RUN chmod +x docker-entrypoint.sh
# ports needed when running this image
EXPOSE 48782
EXPOSE 48772

# switch to lethean
USER lthn

ENTRYPOINT ["./docker-entrypoint.sh", "daemon"]


