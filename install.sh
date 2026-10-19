#!/usr/bin/env bash
# ==============================================================================
#   macOS Sequoia Setup for Omarchy / Hyprland
#  Completely automated 1-command installer: Frosted Glass blur, Dwindle Tiling,
#  Spaces Gestures, Drop Shadows, SF Typography, Dynamic Cursor & Helper Scripts.
# ==============================================================================

set -eo pipefail

# ANSI Color codes
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

cat << "EOF"
    __  ___            ____  _____   _____                      _       
   /  |/  /___ ______ / __ \/ ___/  / ___/___  ____ ___  ______(_)___ _ 
  / /|_/ / __ `/ ___// / / /\__ \   \__ \/ _ \/ __ `/ / / / __  / __ `/ 
 / /  / / /_/ / /__ / /_/ /___/ /  ___/ /  __/ /_/ / /_/ / /_/ / /_/ /  
/_/  /_/\__,_/\___/ \____//____/  /____/\___/\__, /\__,_/\__,_/\__,_/   
                                               /_/                       
EOF
echo -e "${BOLD}${CYAN}==> Automated macOS Sequoia Theme & Frosted Glass Installer${NC}\n"

THEME_DIR="$HOME/.config/omarchy/themes/macos"
BIN_DIR="$HOME/.local/bin"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
HYPR_DIR="$HOME/.config/hypr"
REPO_URL="https://github.com/ayush-rdev/omarchy-macos-theme.git"

mkdir -p "$BIN_DIR" "$SYSTEMD_USER_DIR" "$HYPR_DIR"

# ------------------------------------------------------------------------------
# 1. Fetch & Install macOS Theme
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [1/9] Deploying macOS theme files..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"

if [[ -n "$SCRIPT_DIR" && -f "$SCRIPT_DIR/hyprland.lua" && -f "$SCRIPT_DIR/colors.toml" ]]; then
  echo -e "    Using local theme files from $SCRIPT_DIR"
  mkdir -p "$THEME_DIR"
  cp -rf "$SCRIPT_DIR"/* "$THEME_DIR/"
else
  echo -e "    Cloning macOS theme repository..."
  TEMP_CLONE="$(mktemp -d)"
  git clone --depth=1 "$REPO_URL" "$TEMP_CLONE" 2>/dev/null || {
    echo -e "${YELLOW}Warning: Git clone failed, retrying...${NC}"
    git clone "$REPO_URL" "$TEMP_CLONE"
  }
  mkdir -p "$THEME_DIR"
  cp -rf "$TEMP_CLONE"/* "$THEME_DIR/"
  rm -rf "$TEMP_CLONE"
fi

# CRITICAL FOR OMARCHY:
# Remove .git from ~/.config/omarchy/themes/macos so Omarchy recognizes this as
# an authentic user theme and preserves hyprland.lua, animations, borders, and terminals!
rm -rf "$THEME_DIR/.git" "$THEME_DIR/.gitignore" 2>/dev/null || true

# ------------------------------------------------------------------------------
# 2. Deploy Frosted Glass Rice Effect & Blur ("blut")
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [2/9] Configuring Frosted Glass & Dual Kawase blur..."
if [[ -f "$THEME_DIR/glass.lua" ]]; then
  cp -f "$THEME_DIR/glass.lua" "$HYPR_DIR/glass.lua"
fi

# Enable glass toggle in Omarchy dynamic toggles
TOGGLES_DIR="$HOME/.local/state/omarchy/toggles/hypr"
mkdir -p "$TOGGLES_DIR"
if [[ -f "$HYPR_DIR/glass.lua" ]]; then
  cp -f "$HYPR_DIR/glass.lua" "$TOGGLES_DIR/glass.lua"
fi

# Enable status bar transparency for translucent macOS bar
if command -v omarchy >/dev/null 2>&1; then
  omarchy bar transparent true 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 3. Deploy Helper Scripts (Spaces, Glass Toggle, Window Hide/Unhide)
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [3/9] Installing macOS management scripts to $BIN_DIR..."
if [[ -d "$THEME_DIR/scripts" ]]; then
  cp -f "$THEME_DIR/scripts/"* "$BIN_DIR/"
  chmod +x "$BIN_DIR/omarchy-toggle-fullscreen-space" \
           "$BIN_DIR/omarchy-spaces-listener" \
           "$BIN_DIR/omarchy-close-workspace-windows" \
           "$BIN_DIR/omarchy-window-hide" \
           "$BIN_DIR/omarchy-glass-toggle" \
           "$BIN_DIR/toggle-window-switcher" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 4. Enable Background Spaces Auto-Clean Daemon
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [4/9] Enabling macOS Spaces auto-clean background daemon..."
cat << 'EOF' > "$SYSTEMD_USER_DIR/omarchy-spaces-listener.service"
[Unit]
Description=macOS Spaces Auto-Clean & Return daemon for Hyprland
PartOf=graphical-session.target
After=graphical-session.target

[Service]
Type=simple
ExecStart=%h/.local/bin/omarchy-spaces-listener
Restart=always
RestartSec=2s

[Install]
WantedBy=graphical-session.target
EOF

systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable --now omarchy-spaces-listener.service 2>/dev/null || true

# ------------------------------------------------------------------------------
# 5. Configure Hyprland Keybindings
# ------------------------------------------------------------------------------
HYPR_BINDINGS="$HYPR_DIR/bindings.lua"
echo -e "${BLUE}==>${NC} [5/9] Setting up macOS shortcuts & window management bindings..."

if [[ -f "$HYPR_BINDINGS" ]]; then
  # Glass Toggle binding (Super + Alt + Backspace)
  if ! grep -q "omarchy-glass-toggle" "$HYPR_BINDINGS"; then
    cat << 'EOF' >> "$HYPR_BINDINGS"

-- Glass Rice Effect (Optimized Dual Kawase blur & translucent windows)
o.bind("SUPER + ALT + BACKSPACE", "Toggle Glass Effect", "omarchy-glass-toggle")
EOF
  fi

  # Spaces and Window management shortcuts
  if ! grep -q "omarchy-toggle-fullscreen-space" "$HYPR_BINDINGS"; then
    cat << 'EOF' >> "$HYPR_BINDINGS"

-- macOS Theme Shortcuts & Fullscreen Spaces
hl.unbind("SUPER + F")
o.bind("SUPER + F", "Toggle fullscreen space", os.getenv("HOME") .. "/.local/bin/omarchy-toggle-fullscreen-space")
o.bind("mouse:274", "Toggle fullscreen space", os.getenv("HOME") .. "/.local/bin/omarchy-toggle-fullscreen-space", { mouse = true })
o.bind("SUPER + ALT + F", "Full screen", hl.dsp.window.fullscreen({ mode = "fullscreen" }))

hl.unbind("SUPER + H")
hl.unbind("SUPER + ALT + H")
o.bind("SUPER + H", "Hide window", os.getenv("HOME") .. "/.local/bin/omarchy-window-hide")
o.bind("SUPER + ALT + H", "Unhide window", os.getenv("HOME") .. "/.local/bin/omarchy-window-hide unhide")

o.bind("SUPER + ALT + W", "Close all windows in workspace", os.getenv("HOME") .. "/.local/bin/omarchy-close-workspace-windows")

hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + ALT + " .. key)
  o.bind("SUPER + ALT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end
EOF
  fi
fi

# ------------------------------------------------------------------------------
# 6. Configure Touchpad Gestures
# ------------------------------------------------------------------------------
HYPR_INPUT="$HYPR_DIR/input.lua"
echo -e "${BLUE}==>${NC} [6/9] Configuring macOS Touchpad Gestures..."

if [[ -f "$HYPR_INPUT" ]] && ! grep -q "toggle-window-switcher" "$HYPR_INPUT"; then
  cat << 'EOF' >> "$HYPR_INPUT"

-- macOS Touchpad gestures (3-finger swipe to slide spaces, 3-finger swipe up for window switcher, 3-finger swipe down to close window)
hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.gesture({
  fingers = 3,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd(os.getenv("HOME") .. "/.local/bin/toggle-window-switcher"))
  end,
})
hl.gesture({
  fingers = 3,
  direction = "down",
  action = function()
    hl.dispatch(hl.dsp.window.close())
  end,
})
EOF
fi

# ------------------------------------------------------------------------------
# 7. Setup macOS Dynamic Cursor & Lock/Boot Designs
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [7/9] Setting up Dynamic Cursor and Apple Lock Screen..."

PLUGINS_DIR="$HYPR_DIR/plugins"
mkdir -p "$PLUGINS_DIR"
if [[ -f "$THEME_DIR/plugins/dynamic-cursors.so" ]]; then
  cp -f "$THEME_DIR/plugins/dynamic-cursors.so" "$PLUGINS_DIR/dynamic-cursors.so"

  HYPR_MAIN="$HYPR_DIR/hyprland.lua"
  if [[ -f "$HYPR_MAIN" ]] && ! grep -q "dynamic-cursors.so" "$HYPR_MAIN"; then
    cat << 'EOF' >> "$HYPR_MAIN"

-- Load dynamic cursor plugin for macOS-like shake to find
hl.plugin.load(os.getenv("HOME") .. "/.config/hypr/plugins/dynamic-cursors.so")
EOF
  fi

  hyprctl plugin load "$PLUGINS_DIR/dynamic-cursors.so" 2>/dev/null || true
fi

# Lock Screen & Boot Screen designs
if [[ -d "$THEME_DIR/lock-designs" ]]; then
  mkdir -p "$HOME/.config/omarchy/lock-designs"
  cp -f "$THEME_DIR/lock-designs/"* "$HOME/.config/omarchy/lock-designs/" 2>/dev/null || true
fi

if [[ -d "$THEME_DIR/boot-designs" ]]; then
  mkdir -p "$HOME/.config/omarchy/boot-designs"
  cp -f "$THEME_DIR/boot-designs/"* "$HOME/.config/omarchy/boot-designs/" 2>/dev/null || true
fi

# ------------------------------------------------------------------------------
# 8. Apple Typography & Fonts (SFMono Nerd Font Ligaturized)
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [8/9] Verifying Apple SF Pro & SFMono Fonts..."
FONT_DIR="$HOME/.local/share/fonts/apple-sf"

if ! fc-list : family 2>/dev/null | grep -iq "Liga SFMono Nerd Font"; then
  echo -e "    Installing Liga SFMono Nerd Font..."
  mkdir -p "$FONT_DIR"
  TEMP_FONT_DIR="$(mktemp -d)"
  if git clone --depth=1 https://github.com/shaunsingh/SFMono-Nerd-Font-Ligaturized.git "$TEMP_FONT_DIR" 2>/dev/null; then
    cp -f "$TEMP_FONT_DIR"/*.otf "$FONT_DIR/" 2>/dev/null || true
    rm -rf "$TEMP_FONT_DIR"
    fc-cache -f "$HOME/.local/share/fonts" 2>/dev/null || true
  fi
fi

if command -v omarchy >/dev/null 2>&1 && fc-list : family 2>/dev/null | grep -iq "Liga SFMono Nerd Font"; then
  omarchy font set "Liga SFMono Nerd Font" 2>/dev/null || true
fi

# Optional: GNOME Sushi Quick Look (Spacebar file preview)
if command -v pacman >/dev/null 2>&1 && ! command -v sushi >/dev/null 2>&1; then
  if sudo -n true 2>/dev/null; then
    sudo pacman -S --noconfirm --needed sushi 2>/dev/null || true
  fi
fi

if [[ -f "$THEME_DIR/patches/org.gnome.NautilusPreviewer.src.gresource" && -d "/usr/share/sushi" ]]; then
  if sudo -n true 2>/dev/null; then
    sudo cp -f "$THEME_DIR/patches/org.gnome.NautilusPreviewer.src.gresource" "/usr/share/sushi/org.gnome.NautilusPreviewer.src.gresource" 2>/dev/null || true
    pkill -f NautilusPreviewer 2>/dev/null || true
  fi
fi

# ------------------------------------------------------------------------------
# 9. Apply Theme & Reload Session
# ------------------------------------------------------------------------------
echo -e "${BLUE}==>${NC} [9/9] Activating macOS Sequoia theme..."
if command -v omarchy >/dev/null 2>&1; then
  omarchy theme set macos
  omarchy restart shell 2>/dev/null || true
fi

hyprctl reload >/dev/null 2>&1 || true

echo -e "\n${BOLD}${GREEN}================================================================${NC}"
echo -e "${BOLD}${GREEN}   macOS Sequoia Theme & Frosted Glass Successfully Installed! ${NC}"
echo -e "${BOLD}${GREEN}================================================================${NC}\n"

echo -e "${BOLD}${MAGENTA}✨ Keybindings & Gestures Cheat-Sheet:${NC}"
echo -e "  • ${CYAN}Super + Alt + Backspace${NC} : Toggle Frosted Glass Blur & Translucency"
echo -e "  • ${CYAN}Super + F${NC}               : macOS Fullscreen Space (dedicated workspace)"
echo -e "  • ${CYAN}Super + H${NC}               : Hide window to scratchpad"
echo -e "  • ${CYAN}Super + Alt + H${NC}         : Unhide window from scratchpad"
echo -e "  • ${CYAN}Super + Alt + W${NC}         : Close all windows in current workspace"
echo -e "  • ${CYAN}Super + Tab${NC}             : Next workspace (smooth slide animation)"
echo -e "  • ${CYAN}3-Finger Swipe ↔${NC}        : Slide between macOS spaces horizontally"
echo -e "  • ${CYAN}3-Finger Swipe ↑${NC}        : Open Spotlight Window Switcher"
echo -e "  • ${CYAN}3-Finger Swipe ↓${NC}        : Close active window"
echo -e "  • ${CYAN}Shake Mouse Rapidly${NC}     : Enlarge cursor (macOS Shake to Find)\n"
