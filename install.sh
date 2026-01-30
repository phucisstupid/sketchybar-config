#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

trap 'echo -e "\n\033[0;31m✘ Interrupted. Exiting...\033[0m"; exit 1' INT

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
RESET="\033[0m"

log()     { echo -e "${YELLOW}➤ $1${RESET}"; }
success() { echo -e "${GREEN}✔ $1${RESET}"; }
error()   { echo -e "${RED}✘ $1${RESET}" >&2; }

get_yes_no() {
  local prompt="$1" response
  read -rp "$prompt (y/n) " response || return 1
  [[ "$response" =~ ^[Yy]$ ]]
}

backup_file() {
  local target="$1"
  [[ -e "$target" ]] && mv "$target" "$target.bak"
}

CONFIG_DIR="$HOME/.config"

# sanity checks
command -v brew >/dev/null || { error "Homebrew not found"; exit 1; }
command -v curl >/dev/null || { error "curl not found"; exit 1; }

backup_file "$CONFIG_DIR/sketchybar"
git clone --depth 1 https://github.com/phucisstupid/sketchybar-config "$CONFIG_DIR/sketchybar"
success "Cloned SketchyBar config."

if get_yes_no "✨ Install SketchyBar dependencies and helpers?"; then

  if ! command -v jq >/dev/null; then
    log "Installing jq..."
    brew install jq
  fi

  log "Fetching latest icon_map.lua..."
  latest_tag=$(curl -fsSL https://api.github.com/repos/kvndrsslr/sketchybar-app-font/releases/latest \
    | jq -r .tag_name)

  output_path="$CONFIG_DIR/sketchybar/helpers/spaces_util/icon_map.lua"
  mkdir -p "$(dirname "$output_path")"

  curl -fsSL \
    "https://github.com/kvndrsslr/sketchybar-app-font/releases/download/${latest_tag}/icon_map.lua" \
    -o "$output_path"

  log "Installing dependencies..."
  brew install lua switchaudio-osx media-control
  brew tap FelixKratz/formulae
  brew install sketchybar
  brew install --cask font-sketchybar-app-font font-maple-mono-nf

  log "Installing SbarLua..."
  tmpdir=$(mktemp -d)
  git clone --depth 1 https://github.com/FelixKratz/SbarLua.git "$tmpdir"
  (cd "$tmpdir" && make install)
  rm -rf "$tmpdir"
fi

brew services restart sketchybar || true
sketchybar --reload || true
success "✅ SketchyBar installation complete."
