-- Glass Rice Effect for Omarchy / Hyprland
-- High-efficiency Dual Kawase frosted glass tuned for performance, low thermals, and snappiness.

hl.config({
  decoration = {
    blur = {
      enabled = true,
      size = 6,                 -- Creamy frosted radius without excessive pixel sampling
      passes = 2,               -- Dual Kawase 2-pass: maximum smoothness with minimal shader overhead
      new_optimizations = true, -- Skips rendering blur on occluded pixels (major GPU power & fill-rate saver)
      xray = false,             -- Smooth natural backdrop blur
      ignore_opacity = true,    -- Crisp frosted diffusion underneath translucent surfaces
      popups = true,            -- Apply to popup menus & tooltips
      popups_ignorealpha = 0.2,
    },
  },
})

-- Layer surface blur (Omarchy status bar, quickshell menus, notifications, OSD)
hl.layer_rule({ match = { namespace = "omarchy-bar" }, blur = true, ignore_alpha = 0.2 })
hl.layer_rule({
  match = {
    namespace = "^(omarchy-menu|omarchy-image-selector|omarchy-emojis|omarchy-clipboard|omarchy-keyboard-panel|omarchy-notifications|omarchy-osd)$",
  },
  blur = true,
  ignore_alpha = 0.2,
})

-- Translucent window opacity (balanced for high text contrast + visible frosted depth)
o.window({ tag = "default-opacity" }, { opacity = "0.91 0.84" })
o.window({ tag = "terminal" }, { opacity = "0.86 0.78" })
o.window({ tag = "chromium-based-browser" }, { opacity = "0.94 0.88" })
o.window({ tag = "firefox-based-browser" }, { opacity = "0.94 0.88" })
o.window("org.gnome.Nautilus", { opacity = "0.90 0.82" })
