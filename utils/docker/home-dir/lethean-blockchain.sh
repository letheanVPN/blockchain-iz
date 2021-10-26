#!/bin/sh

case $1 in

daemon)
  shift
  echo "Starting Lethean Daemon"
  "$BIN_DIR/letheand" --non-interactive --detach --standard-json --config-file="$CONF_DIR" --log-file "$LOG_DIR" --data-dir "$DATA_DIR"
  ;;

docker)
  shift
  echo "Starting Lethean Daemon"
  "$BIN_DIR/letheand" --non-interactive --rpc-bind-ip=0.0.0.0 --confirm-external-bind --standard-json --config-file="$CONF_DIR" --log-level 0 --log-file "$LOG_DIR" --data-dir "$DATA_DIR"
  ;;

export)
  shift
  echo "Exporting Chain"
  "$BIN_DIR/lethean-blockchain-export" --data-dir "$DATA_DIR" --output-file "$DATA_DIR/export.raw"
  ;;

import)
  shift
  echo "Exporting Chain"
  "$BIN_DIR/lethean-blockchain-import" --data-dir "$DATA_DIR" --input-file "$DATA_DIR/export.raw"
  ;;

*)
  echo "daemon|docker|export"
esac
