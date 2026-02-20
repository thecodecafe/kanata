#!/usr/bin/env bash
set -euo pipefail

PLIST="/Library/LaunchDaemons/kanata.plist"
LABEL="kanata"
LOG_TAG="[kanatactl]"

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $LOG_TAG $*"
}

require_root() {
  if [[ $EUID -ne 0 ]]; then
    log "Re-running with sudo"
    exec sudo "$0" "$@"
  fi
}

is_running() {
  launchctl list | grep -q "$LABEL"
}

start() {
  if is_running; then
    log "Kanata already running"
    return 0
  fi
  log "Starting Kanata"
  launchctl bootstrap system "$PLIST"
  log "Kanata started"
}

stop() {
  log "Stopping Kanata (if running)"
  launchctl bootout system "$PLIST" 2>/dev/null || true
  log "Kanata stopped"
}

restart() {
  log "Restarting Kanata"
  stop
  start
}

status() {
  if is_running; then
    log "Kanata is running"
    launchctl list | grep "$LABEL"
  else
    log "Kanata is NOT running"
  fi
}

usage() {
  cat <<EOF
Usage: kanata.sh <command>

Commands:
  start     Start Kanata if not running
  stop      Stop Kanata if running
  restart   Restart Kanata
  status    Show Kanata status
EOF
}

main() {
  require_root "$@"

  case "${1:-}" in
    start) start ;;
    stop) stop ;;
    restart) restart ;;
    status) status ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"