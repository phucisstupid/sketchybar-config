#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

# ----------------------
# 🎨 COLORS & LOGGING
# ----------------------
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

log()     { echo -e "${YELLOW}➤ $*${RESET}"; }
success() { echo -e "${GREEN}✔ $*${RESET}"; }
error()   { echo -e "${RED}✘ $*${RESET}" >&2; }

trap 'error "Interrupted. Exiting..."; exit 1' INT

# ----------------------
# 🧰 HELPERS
# ----------------------
get_yes_no() {
  local reply
  while true; do
    read -rp "$1 (y/n): " reply || return 1
    case "$reply" in
      [Yy]) return 0 ;;
      [Nn]) return 1 ;;
      *) echo "Please answer y or n." ;;
    esac
  done
}

backup_file() {
  [[ -e "$1" ]] && mv "$1" "$1.bak"
}

require_cmd() {
  command -v "$1" >/dev/null || { error "$1 not found"; exit 1; }
}

# ----------------------
# 📁 PATHS
# ----------------------
CONFIG_DIR="$HOME/.config"
SKETCHYBAR_DIR="$CONFIG_DIR/sketchybar"

# ----------------------
# ✅ SANITY CHECKS
# ----------------------
require_cmd brew
require_cmd curl

# ----------------------
# 📦 INSTALL CONFIG
# ----------------------
backup_file "$SKETCHYBAR_DIR"
git clone --depth 1 https://github.com/phucisstupid/sketchybar-config "$SKETCHYBAR_DIR"
success "Cloned SketchyBar config."

# ----------------------
# ⚙ OPTIONAL DEPS
# ----------------------
if get_yes_no "✨ Install SketchyBar dependencies and helpers?"; then

  if ! command -v jq >/dev/null; then
    log "Installing jq..."
    brew install jq
  fi

  log "Fetching latest icon_map.lua..."
  latest_tag="$(curl -fsSL https://api.github.com/repos/kvndrsslr/sketchybar-app-font/releases/latest \
    | jq -r '.tag_name')"

  icon_path="$SKETCHYBAR_DIR/helpers/spaces_util/icon_map.lua"
  mkdir -p "$(dirname "$icon_path")"

  curl -fsSL \
    "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${latest_tag}/icon_map.lua" \
    -o "$icon_path"

  log "Installing dependencies..."
  brew tap FelixKratz/formulae
  brew install lua switchaudio-osx media-control sketchybar
  brew install --cask font-sketchybar-app-font font-maple-mono-nf

  log "Installing SbarLua..."
  tmpdir="$(mktemp -d)"
  git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$tmpdir"
  (cd "$tmpdir" && make install)
  rm -rf "$tmpdir"
fi

# ----------------------
# 🔄 RELOAD
# ----------------------
brew services restart sketchybar || true
sketchybar --reload || true
success "SketchyBar installation complete."
