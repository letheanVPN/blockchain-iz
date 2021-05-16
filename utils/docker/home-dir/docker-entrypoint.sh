#!/bin/sh

case $1 in

daemon)
  shift
  echo "Starting Lethean Daemon"

  /home/lthn/chain/bin/letheand --non-interactive --standard-json --config-file="${LETHEAND_CONFIG}" --log-file "${LETHEAND_LOG}" --data-dir "${LETHEAND_DATA}"

  ;;


*)
  echo "daemon"
esac