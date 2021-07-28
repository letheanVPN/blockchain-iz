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
  "$BIN_DIR/letheand" --non-interactive --standard-json --config-file="$CONF_DIR" --log-file "$LOG_DIR" --data-dir "$DATA_DIR"
  ;;

sh|bash)
  /bin/sh
  ;;
*)
  echo "daemon|docker|sh"
esac