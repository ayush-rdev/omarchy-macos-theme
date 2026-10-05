#!/usr/bin/env bash
# macOS Sequoia Uninstall Script for Omarchy
# Cleans up all scripts, systemd background services, dynamic cursor plugins, and restores original configuration.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}==>${NC} Uninstalling macOS Sequoia Theme and Extensions..."

# 1. Stop and remove the Spaces daemon systemd service
echo -e "${BLUE}==>${NC} Stopping and removing background spaces daemon..."
systemctl --user stop omarchy-spaces-listener.service 2>/dev/null || true
systemctl --user disable omarchy-spaces-listener.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/omarchy-spaces-listener.service"
rm -f "$HOME/.config/systemd/user/graphical-session.target.wants/omarchy-spaces-listener.service"
systemctl --user daemon-reload 2>/dev/null || true
pkill -f omarchy-spaces-listener 2>/dev/null || true

# 2. Unload and remove dynamic-cursors plugin
echo -e "${BLUE}==>${NC} Removing dynamic cursor plugin..."
hyprctl plugin unload "$HOME/.config/hypr/plugins/dynamic-cursors.so" 2>/dev/null || true
rm -f "$HOME/.config/hypr/plugins/dynamic-cursors.so"

# 3. Remove installed helper scripts
echo -e "${BLUE}==>${NC} Removing helper scripts..."
rm -f "$HOME/.local/bin/omarchy-toggle-fullscreen-space" \
      "$HOME/.local/bin/omarchy-spaces-listener" \
      "$HOME/.local/bin/omarchy-close-workspace-windows" \
      "$HOME/.local/bin/omarchy-window-hide" \
      "$HOME/.local/bin/toggle-window-switcher" \
      "/tmp/hypr_macos_spaces_state.json"

# 4. Clean up theme references from hyprland configuration files
echo -e "${BLUE}==>${NC} Cleaning up Hyprland configs..."
HYPR_MAIN="$HOME/.config/hypr/hyprland.lua"
HYPR_LOOK="$HOME/.config/hypr/looknfeel.lua"
HYPR_BINDINGS="$HOME/.config/hypr/bindings.lua"
HYPR_INPUT="$HOME/.config/hypr/input.lua"

if [[ -f "$HYPR_MAIN" ]]; then
  sed -i '/dynamic-cursors.so/d' "$HYPR_MAIN"
fi

if [[ -f "$HYPR_LOOK" ]]; then
  # Remove dynamic_cursors block if present
  python3 -c '
import sys, re
path = sys.argv[1]
try:
    with open(path, "r") as f:
        content = f.read()
    content = re.sub(r"-- macOS \"Shake to Find\"[\s\S]*?fallback = \"clientside\",\s*},\s*},\s*},\s*\}\)", "", content)
    with open(path, "w") as f:
        f.write(content)
except Exception:
    pass
' "$HYPR_LOOK" 2>/dev/null || true
fi

if [[ -f "$HYPR_BINDINGS" ]]; then
  sed -i '/omarchy-toggle-fullscreen-space/d' "$HYPR_BINDINGS"
  sed -i '/omarchy-spaces-listener/d' "$HYPR_BINDINGS"
  sed -i '/omarchy-close-workspace-windows/d' "$HYPR_BINDINGS"
  sed -i '/omarchy-window-hide/d' "$HYPR_BINDINGS"
fi

if [[ -f "$HYPR_INPUT" ]]; then
  sed -i '/toggle-window-switcher/d' "$HYPR_INPUT"
  sed -i '/macOS Touchpad gestures/d' "$HYPR_INPUT"
  sed -i '/hl.gesture({ fingers = 3/d' "$HYPR_INPUT"
  sed -i '/hl.dsp.window.close()/d' "$HYPR_INPUT"
fi

# 5. Restore stock GNOME Sushi if modified
if command -v pacman >/dev/null 2>&1 && command -v sushi >/dev/null 2>&1; then
  echo -e "${BLUE}==>${NC} Restoring stock GNOME Sushi package..."
  sudo pacman -S --noconfirm sushi 2>/dev/null || true
fi

# 6. Remove macOS Now Playing plugin
rm -rf "$HOME/.config/omarchy/plugins/macos.nowplaying"
if [[ -f "$HOME/.config/omarchy/shell.json" ]]; then
  python3 -c '
import json, sys
path = sys.argv[1]
try:
    with open(path, "r") as f:
        data = json.load(f)
    right = data.get("bar", {}).get("layout", {}).get("right", [])
    data["bar"]["layout"]["right"] = [item for item in right if item.get("id") != "macos.nowplaying"]
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
except Exception:
    pass
' "$HOME/.config/omarchy/shell.json" 2>/dev/null || true
  omarchy restart shell 2>/dev/null || true
fi

# 7. Remove theme files and switch to an Omarchy default theme
echo -e "${BLUE}==>${NC} Removing theme files..."
omarchy theme remove macos 2>/dev/null || rm -rf "$HOME/.config/omarchy/themes/macos"

# Reload Hyprland to apply clean state
hyprctl reload >/dev/null 2>&1 || true

echo -e "${GREEN}==>${NC} macOS Sequoia Theme and all associated scripts completely removed! 🧹"
