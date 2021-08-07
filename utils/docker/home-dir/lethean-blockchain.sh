#!/bin/sh

case $1 in

wallet-rpc)
  shift
  echo "Starting Wallet cli with $WALLET_FILE."
  "$BIN_DIR/lethean-wallet-rpc" --wallet-file "$WALLET_FILE" --daemon-host $DAEMON_HOST --password $WALLET_PASSWORD --rpc-bind-port $PORT_RPC --confirm-external-bind --trusted-daemon
  ;;

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
