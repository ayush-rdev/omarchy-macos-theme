# macOS Sequoia Theme for Omarchy

An authentic Apple macOS Sequoia experience crafted for the **Omarchy Hyprland Desktop**, combining translucent frosted glass surfaces, subtle Retina 1px glass rim borders, Apple spring animation physics, native macOS Spaces, fluid gestures, and dynamic cursor magnification.

![Preview](preview.png)

---

## 🌟 What Makes This Theme Authentic

* **Glass Hairline Borders (Retina 1px)**: Replaces harsh neon borders with subtle translucent glass reflection (`rgba(ffffff28)` active, `rgba(ffffff10)` inactive) designed to blend with soft 36px macOS drop shadows.
* **Apple Spring & Deceleration Physics**: Custom fluid cubic-bezier curves (`macEase`, `macSpring`, `macSpace`) matching macOS Mission Control and Spaces transitions.
* **macOS "Shake to Find" Dynamic Cursor**: Rapidly shaking your mouse dynamically enlarges the cursor to find it easily, then smoothly scales back down with zero wobble or tilt distortion.
* **Native macOS Spaces Workflow**: Dedicated fullscreen spaces that don't resize your window awkwardly. When a fullscreen app is closed, the space automatically destroys itself and returns you to your previous desktop.
* **Touchpad Gestures**: Natural 3-finger horizontal swipes to glide between spaces, and 3-finger swipe up to reveal open windows.
* **Curated 4K Apple Wallpapers**: Dynamic light and dark 4K wallpapers from macOS Sequoia, Sonoma, Ventura, Monterey, and Big Sur.

---

## ⚡ Quick 1-Command Automatic Install (Recommended)

Install everything automatically in one single command (theme, helper scripts, gestures, shortcuts, dynamic cursor plugin, and spaces daemon):

```bash
curl -fsSL https://raw.githubusercontent.com/ayush-rdev/omarchy-macos-theme/master/install.sh | bash
```

*(Or if you cloned the repository locally: `./install.sh`)*

---

## 🕹️ How to Use It (macOS Workflow Guide)

### 1. Spaces & Fullscreen Experience
| Action | Shortcut / Gesture | What Happens |
| :--- | :--- | :--- |
| **Enter Dedicated Space** | <kbd>Win</kbd> + <kbd>F</kbd> *(or 3-finger click)* | Moves the active app into its own clean fullscreen space with zero resize bounce. |
| **Exit Dedicated Space** | <kbd>Win</kbd> + <kbd>F</kbd> | Returns the app back to its previous workspace. |
| **Auto-Destruction on Close** | <kbd>Win</kbd> + <kbd>W</kbd> or <kbd>Cmd</kbd> + <kbd>Q</kbd> | If you close the app while in its dedicated space, the space is destroyed and you automatically slide back to your previous space. |
| **Standard Fullscreen** | <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>F</kbd> | Classic fullscreen mode on the current workspace. |

### 2. Smooth Navigation & Gestures
| Action | Shortcut / Gesture | What Happens |
| :--- | :--- | :--- |
| **Slide Between Spaces** | **3-Finger Swipe Left / Right** | Silky-smooth horizontal slide between workspaces. |
| **Next Space** | <kbd>Win</kbd> + <kbd>Tab</kbd> | Rapidly cycle to the next workspace. |
| **Spotlight Window Switcher**| **3-Finger Swipe Up** | Pops up the Spotlight-style window menu to jump to any window. |
| **Move Window & Follow** | <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>1..10</kbd> | Sends window to space 1–10 and switches view with it. |
| **Move Window Silently** | <kbd>Win</kbd> + <kbd>Shift</kbd> + <kbd>1..10</kbd>| Sends window to space 1–10 without leaving your current workspace. |

### 3. Window Management & Productivity
| Action | Shortcut | What Happens |
| :--- | :--- | :--- |
| **Hide Window** | <kbd>Win</kbd> + <kbd>H</kbd> | Seamlessly hides the active window into the scratchpad. |
| **Unhide Window** | <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>H</kbd> | Restores hidden windows onto the active workspace so `Alt + Tab` and Spotlight switcher see them immediately. |
| **Close All in Workspace** | <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>W</kbd> | Instantly closes all windows open in your active workspace only. |
| **Clipboard History** | <kbd>Win</kbd> + <kbd>V</kbd> | Opens the Omarchy frosted-glass clipboard history panel. |
| **Capture Menu** | <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>C</kbd> | Interactive screenshot and screen record utility. |
| **Extract Text (OCR)** | <kbd>Win</kbd> + <kbd>Alt</kbd> + <kbd>Print</kbd> | Drag an area to copy its text directly to your clipboard. |

### 4. Shake to Find Cursor
* Simply give your mouse or trackpad a quick, rapid shake across the screen. The cursor smoothly enlarges up to 5.5× and gracefully shrinks back when movement calms down.

---

## 🛠️ Manual Step-by-Step Installation

If you prefer configuring things manually:

### 1. Install & Apply the Theme
```bash
omarchy theme install https://github.com/ayush-rdev/omarchy-macos-theme.git
omarchy theme set macos
```

### 2. Install Helper Scripts
```bash
cp ~/.config/omarchy/themes/macos/scripts/* ~/.local/bin/
chmod +x ~/.local/bin/omarchy-* ~/.local/bin/toggle-window-switcher
```

### 3. Enable the Spaces Auto-Clean Daemon
Add the daemon to `~/.config/hypr/autostart.lua`:
```lua
o.launch_on_start("omarchy-spaces-listener")
```

### 4. Enable Dynamic Cursors (Shake to Find)
Copy the bundled plugin:
```bash
mkdir -p ~/.config/hypr/plugins
cp ~/.config/omarchy/themes/macos/plugins/dynamic-cursors.so ~/.config/hypr/plugins/
```
Load the plugin in `~/.config/hypr/hyprland.lua`:
```lua
hl.plugin.load(os.getenv("HOME") .. "/.config/hypr/plugins/dynamic-cursors.so")
```
Add the wobble-free configuration to `~/.config/hypr/looknfeel.lua`:
```lua
hl.config({
  plugin = {
    dynamic_cursors = {
      enabled = true,
      mode = "none", -- Disables tilt and wobble for clean macOS scaling
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

## 📜 Helper Scripts Reference

All scripts reside in `scripts/` and integrate directly with Hyprland's socket API:
* **`omarchy-toggle-fullscreen-space`**: Dispatches the active window into an empty workspace with single-app full layout (avoiding jarring resize animations).
* **`omarchy-spaces-listener`**: Background event daemon that monitors Hyprland's `closewindow` and `workspacev2` events to clean up empty spaces automatically.
* **`omarchy-close-workspace-windows`**: Safely closes all client windows residing on the current workspace.
* **`omarchy-window-hide`**: Wraps scratchpad hiding/unhiding cleanly into macOS `Cmd + H` muscle memory.
* **`toggle-window-switcher`**: Renders a Spotlight-styled fuzzy searchable list of all open windows across monitors.

---

## 🧹 Complete Uninstallation

To cleanly remove the theme, all helper scripts, background services, cursor plugins, and restore your system:

```bash
curl -fsSL https://raw.githubusercontent.com/ayush-rdev/omarchy-macos-theme/master/uninstall.sh | bash
```

*(Or if running from a local clone: `./uninstall.sh`)*
