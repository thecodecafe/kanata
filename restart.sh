#!/usr/bin/env bash

set -euo pipefail

PLIST="/Library/LaunchDaemons/kanata.plist"

echo "🔁 Restarting Kanata (system daemon)…"

echo "→ Stopping Kanata (if running)"
sudo launchctl bootout system "$PLIST" 2>/dev/null || true

echo "→ Starting Kanata"
sudo launchctl bootstrap system "$PLIST"

echo "✅ Kanata restarted"