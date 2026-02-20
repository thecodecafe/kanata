#!/usr/bin/env bash
set -euo pipefail

KANATA_BIN="/opt/homebrew/bin/kanata"
KANATA_CONFIG="$HOME/.config/kanata/kanata.kbd"
PLIST="/Library/LaunchDaemons/kanata.plist"

# Resolve the *real* user home, even under sudo
if [[ -n "${SUDO_USER:-}" ]]; then
  USER_HOME=$(dscl . -read /Users/"$SUDO_USER" NFSHomeDirectory | awk '{print $2}')
else
  USER_HOME="$HOME"
fi

LOG_DIR="$USER_HOME/.local/state/kanata"
LOG_FILE="$LOG_DIR/kanata.log"

mkdir -p "$LOG_DIR"

timestamp() {
  date "+%Y-%m-%d %H:%M:%S"
}

log() {
  echo "[$(timestamp)] $1" | tee -a "$LOG_FILE"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    exec sudo "$0" "$@"
  fi
}

is_running() {
  pgrep -f "$KANATA_BIN.*$KANATA_CONFIG" >/dev/null 2>&1
}

validate_config() {
  log "Validating Kanata configuration"
  if ! "$KANATA_BIN" -c "$KANATA_CONFIG" --check >/dev/null 2>&1; then
    log "ERROR: Kanata configuration validation failed"
    exit 1
  fi
  log "Configuration OK"
}

start_kanata() {
  require_root "$@"

  if is_running; then
    log "Kanata already running"
    exit 0
  fi

  validate_config
  log "Starting Kanata via launchd"
  launchctl bootstrap system "$PLIST" || true
}

stop_kanata() {
  require_root "$@"

  if ! is_running; then
    log "Kanata is not running"
    exit 0
  fi

  log "Stopping Kanata"
  launchctl bootout system "$PLIST" || true
}

restart_kanata() {
  require_root "$@"

  validate_config
  log "Restarting Kanata"
  launchctl bootout system "$PLIST" || true
  launchctl bootstrap system "$PLIST"
}

status_kanata() {
  if is_running; then
    log "Kanata is running"
  else
    log "Kanata is NOT running"
  fi
}

case "${1:-}" in
  start)
    start_kanata "$@"
    ;;
  stop)
    stop_kanata "$@"
    ;;
  restart)
    restart_kanata "$@"
    ;;
  status)
    status_kanata
    ;;
  *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac