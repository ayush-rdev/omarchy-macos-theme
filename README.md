# macOS Sequoia Theme for Omarchy

An authentic Apple macOS Sequoia theme for the **Omarchy Hyprland Desktop**, featuring translucent frosted glass surfaces, SF-inspired palette, refined drop shadows, and authentic macOS Spaces gestures.

![Preview](preview.png)

---

## What's Included

* **Authentic macOS Glass Rim Borders**: 1px subtle Retina translucent glass hairline reflection (`rgba(ffffff28)`) that blends naturally with wide 36px macOS drop shadows.
* **Apple Spring & Deceleration Physics**: Custom fluid cubic-bezier curves (`macEase`, `macSpring`, `macSpace`) matching macOS Mission Control and Spaces transitions.
* **Translucent Frosted Glass Surfaces**: Menu bar, system panels, overlays, and launcher tuned for SF typography and spacing.
* **Optional macOS Spaces & Gestures Experience**: Enhanced scripts for seamless fullscreen spaces, 3-finger horizontal workspace sliding, and Spotlight window switching.

---

## Installation

```bash
omarchy theme install https://github.com/ayush-rdev/omarchy-macos-theme.git
omarchy theme set macos
```

---

## Recommended macOS Keybindings & Gestures

To get the full macOS experience with touchpad gestures and window management, add the following to your Hyprland configuration:

### 1. Touchpad Gestures (`~/.config/hypr/input.lua`)
```lua
-- 3-finger swipe horizontally to slide between workspaces (macOS Spaces)
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

-- 3-finger swipe up to toggle Spotlight Window Switcher
hl.gesture({
  fingers = 3,
  direction = "up",
  action = function()
    hl.dispatch(hl.dsp.exec_cmd("~/.local/bin/toggle-window-switcher"))
  end,
})
```

### 2. Window & Workspace Shortcuts (`~/.config/hypr/bindings.lua`)
```lua
-- macOS Style Fullscreen Spaces (Win + F and 3-finger click)
hl.unbind("SUPER + F")
o.bind("SUPER + F", "Toggle fullscreen space", "~/.local/bin/omarchy-toggle-fullscreen-space")
o.bind("mouse:274", "Toggle fullscreen space", "~/.local/bin/omarchy-toggle-fullscreen-space", { mouse = true })

-- Clean Window Hide / Unhide (Win + H to hide, Win + Alt + H to unhide)
hl.unbind("SUPER + S")
hl.unbind("SUPER + ALT + S")
o.bind("SUPER + H", "Hide window", "~/.local/bin/omarchy-window-hide")
o.bind("SUPER + ALT + H", "Unhide window", "~/.local/bin/omarchy-window-hide unhide")

-- Clipboard manager on Win + V
hl.unbind("SUPER + V")
hl.unbind("SUPER + CTRL + V")
o.bind("SUPER + V", "Clipboard manager", "omarchy-shell shell toggle omarchy.clipboard")

-- Capture Menu & OCR (remapped from Ctrl to Alt)
hl.unbind("SUPER + CTRL + C")
hl.unbind("SUPER + CTRL + PRINT")
o.bind("SUPER + ALT + C", "Capture menu", "omarchy-menu toggle capture")
o.bind("SUPER + ALT + PRINT", "Extract text (OCR) from screenshot", "omarchy-capture-text")

-- Fast Workspace Navigation (Win + Tab)
hl.unbind("SUPER + TAB")
o.bind("SUPER + TAB", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))

-- Move Window to Workspace:
-- Win + Alt + 1..10: Move window and follow
-- Win + Shift + 1..10: Move window silently
for workspace = 1, 10 do
  local key = "code:" .. tostring(workspace + 9)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + ALT + " .. key)
  o.bind("SUPER + ALT + " .. key, "Move window to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. key, "Move window silently to workspace " .. workspace, hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end
```

---

## Helper Scripts (`scripts/`)
Copy the scripts to `~/.local/bin/` to enable dedicated Spaces and Hide/Unhide workflows:
- `omarchy-toggle-fullscreen-space`: Moves active window into its own dedicated space (zero resize bounce) and returns it back on exit.
- `omarchy-window-hide`: Properly hides windows to scratchpad and unhides them onto the active workspace so `Alt + Tab` and Spotlight switcher see them immediately.
- `toggle-window-switcher`: Spotlight-style window menu for all open windows.
