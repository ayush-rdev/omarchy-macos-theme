# macOS Sequoia Theme for Omarchy

An authentic macOS Sequoia theme for the **Omarchy Hyprland Desktop**, featuring translucent frosted glass surfaces, subtle 1px Retina glass rim borders, Apple spring animation physics, native macOS Spaces, fluid gestures, and dynamic cursor magnification.

![Preview](preview.png)

---

## Features

- **Glass Hairline Borders (1px Retina)**: Soft translucent glass reflection (`rgba(ffffff28)` active, `rgba(ffffff10)` inactive) that pairs naturally with deep macOS drop shadows.
- **Apple Spring & Deceleration Physics**: Custom fluid cubic-bezier curves (`macEase`, `macSpring`, `macSpace`) matching macOS Mission Control and Spaces transitions.
- **macOS "Shake to Find" Dynamic Cursor**: Magnifies the cursor when shaken rapidly across the display and smoothly scales down when stationary, with zero tilt or distortion.
- **Native macOS Spaces Workflow**: Dedicated fullscreen spaces with zero window resize jitter. When a dedicated space window closes, the space automatically destroys itself and returns to your previous active workspace.
- **Touchpad Gestures**: 3-finger horizontal swipe to slide between spaces, and 3-finger swipe up to open the window switcher.
- **Curated 4K Apple Wallpapers**: Dynamic light and dark 4K wallpapers from macOS Sequoia, Sonoma, Ventura, Monterey, and Big Sur.

---

## Quick Installation

Run the automated installer script to set up the theme, helper scripts, gestures, shortcuts, dynamic cursor plugin, and spaces background daemon:

```bash
curl -fsSL https://raw.githubusercontent.com/ayush-rdev/omarchy-macos-theme/master/install.sh | bash
```

*Or from a local clone:*
```bash
./install.sh
```

---

## Usage & Keybindings

### Spaces & Fullscreen
| Action | Keybinding / Gesture | Description |
| :--- | :--- | :--- |
| **Enter Dedicated Space** | `Super + F` *(or 3-finger click)* | Moves the focused window into an empty workspace as a dedicated space. |
| **Exit Dedicated Space** | `Super + F` | Returns the window back to its origin workspace. |
| **Auto-Destruction on Close** | `Super + W` / `Super + Alt + W` | Closing the window automatically destroys the space and returns focus to your previous workspace. |
| **Standard Fullscreen** | `Super + Alt + F` | Toggles traditional fullscreen within the current workspace. |

### Navigation & Gestures
| Action | Keybinding / Gesture | Description |
| :--- | :--- | :--- |
| **Slide Workspaces** | **3-Finger Swipe Horizontal** | Slides horizontally across active spaces. |
| **Next Workspace** | `Super + Tab` | Cycles to the next workspace. |
| **Window Switcher** | **3-Finger Swipe Up** | Opens the Spotlight-style window menu. |
| **Move Window & Follow** | `Super + Alt + [1-9]` | Moves active window to workspace `1-9` and switches focus. |
| **Move Window Silently** | `Super + Shift + [1-9]` | Moves active window to workspace `1-9` without switching focus. |

### Window Management
| Action | Keybinding | Description |
| :--- | :--- | :--- |
| **Hide Window** | `Super + H` | Sends active window to scratchpad. |
| **Unhide Window** | `Super + Alt + H` | Restores window onto the current active workspace. |
| **Close All in Workspace** | `Super + Alt + W` | Closes all open windows on the active workspace. |
| **Clipboard History** | `Super + V` | Opens the clipboard manager. |
| **Capture Menu** | `Super + Alt + C` | Opens the screenshot and screen recording menu. |
| **Extract Text (OCR)** | `Super + Alt + Print` | Captures region text directly to clipboard. |

### Shake to Find Cursor
Shake your mouse rapidly back and forth across the screen. The pointer automatically enlarges up to 5.5× and gracefully shrinks back to default size when idle.

---

## Manual Installation

For manual configuration without running the installer script:

### 1. Install & Apply Theme
```bash
omarchy theme install https://github.com/ayush-rdev/omarchy-macos-theme.git
omarchy theme set macos
```

### 2. Copy Helper Scripts
```bash
cp ~/.config/omarchy/themes/macos/scripts/* ~/.local/bin/
chmod +x ~/.local/bin/omarchy-* ~/.local/bin/toggle-window-switcher
```

### 3. Autostart Spaces Daemon
Add the following to `~/.config/hypr/autostart.lua`:
```lua
o.launch_on_start("omarchy-spaces-listener")
```

### 4. Enable Dynamic Cursors Plugin
```bash
mkdir -p ~/.config/hypr/plugins
cp ~/.config/omarchy/themes/macos/plugins/dynamic-cursors.so ~/.config/hypr/plugins/
```

In `~/.config/hypr/hyprland.lua`:
```lua
hl.plugin.load(os.getenv("HOME") .. "/.config/hypr/plugins/dynamic-cursors.so")
```

In `~/.config/hypr/looknfeel.lua`:
```lua
hl.config({
  plugin = {
    dynamic_cursors = {
      enabled = true,
      mode = "none",
      shake = {
        enabled = true,
        threshold = 5.0,
        base = 3.5,
        speed = 4.0,
        limit = 5.5,
        timeout = 1000,
        effects = false,
      },
    },
  },
})
```

---

## Helper Scripts

The `scripts/` directory contains utilities for window management:
- `omarchy-toggle-fullscreen-space`: Manages single-window workspaces without layout bounce.
- `omarchy-spaces-listener`: Background daemon monitoring socket events for space cleanup and compaction.
- `omarchy-close-workspace-windows`: Closes all windows on the active workspace.
- `omarchy-window-hide`: Handles scratchpad show/hide routines.
- `toggle-window-switcher`: Spotlight-style fuzzy window selector.

---

## Uninstallation

To remove the theme, background services, plugins, and helper scripts:

```bash
curl -fsSL https://raw.githubusercontent.com/ayush-rdev/omarchy-macos-theme/master/uninstall.sh | bash
```

*Or from a local clone:*
```bash
./uninstall.sh
```
