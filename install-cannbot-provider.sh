#!/usr/bin/env bash
set -euo pipefail

REPO_RAW="${CANNBOT_REPO_RAW:-https://raw.githubusercontent.com/BadFatCat0919/opencannbot/main}"
PLUGIN_URL="$REPO_RAW/cannbot-auth.js"

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/opencode"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/opencode"
PLUGIN_DIR="$CONFIG_DIR/plugins"
PLUGIN_FILE="$PLUGIN_DIR/cannbot-auth.js"
OPENCODE_JSON="$CONFIG_DIR/opencode.json"

bold()   { printf '\033[1m%s\033[0m\n' "$*"; }
green()  { printf '\033[32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[33m%s\033[0m\n' "$*"; }
red()    { printf '\033[31m%s\033[0m\n' "$*"; }

bold "======================================="
bold "  CANNBOT Provider for OpenCode"
bold "======================================="
echo

command -v opencode >/dev/null 2>&1 || { red "opencode not found. Please install opencode first."; exit 1; }
command -v node >/dev/null 2>&1 || { red "node not found."; exit 1; }

mkdir -p "$PLUGIN_DIR" "$DATA_DIR"

# ── 1. Download plugin ──────────────────────────────────────────────────
# The repo's cannbot-auth.js is the single source of truth.

download() {
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then
    wget -qO "$2" "$1"
  else
    red "Neither curl nor wget found."; exit 1
  fi
}

# If running from a local clone, prefer the local file; otherwise download.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
if [ -f "$SCRIPT_DIR/cannbot-auth.js" ]; then
  cp "$SCRIPT_DIR/cannbot-auth.js" "$PLUGIN_FILE"
  green "[1/2] Plugin copied from local clone -> $PLUGIN_FILE"
else
  download "$PLUGIN_URL" "$PLUGIN_FILE"
  green "[1/2] Plugin downloaded -> $PLUGIN_FILE"
fi

# ── 2. Update opencode.json ─────────────────────────────────────────────

PLUGIN_URI="file://$PLUGIN_FILE"

if [ -f "$OPENCODE_JSON" ]; then
  node -e "
    const fs = require('fs');
    const cfg = JSON.parse(fs.readFileSync('$OPENCODE_JSON', 'utf-8'));
    const plugins = cfg.plugin || [];
    const uri = '$PLUGIN_URI';
    if (!plugins.includes(uri)) plugins.push(uri);
    cfg.plugin = plugins;
    fs.writeFileSync('$OPENCODE_JSON', JSON.stringify(cfg, null, 2) + '\n');
  "
else
  node -e "
    const fs = require('fs');
    const cfg = {
      '\$schema': 'https://opencode.ai/config.json',
      plugin: ['$PLUGIN_URI']
    };
    fs.writeFileSync('$OPENCODE_JSON', JSON.stringify(cfg, null, 2) + '\n');
  "
fi

green "[2/2] opencode.json updated -> $OPENCODE_JSON"

echo
bold "Done! Restart opencode, then run:"
echo
echo "  /connect"
echo
echo "Select 'CANNBOT' and enter your Virtual Key (VK)."
echo
