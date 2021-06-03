#!/bin/sh

# Config part
CONTAINER_NAME=lethean-blockchain
DATA_DIR=~/lthn/data/chain

docker pull lthn/chain
docker stop $CONTAINER_NAME || true
docker rm  $CONTAINER_NAME

# Run Chain Daemon
docker run -d --restart=always \
 -m 1g \
  -p 48782:48782 -p 48772:48772 \
  -v $DATA_DIR:/home/lthn/data/chain \
  --hostname $CONTAINER_NAME \
  --name $CONTAINER_NAME \
  lthn/chain