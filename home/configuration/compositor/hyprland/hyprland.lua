---@diagnostic disable: undefined-global
require("plugins")
require("monitors")
-- https://wiki.hyprland.org/Configuring/
-----------------
--- Variables ---
-----------------

local terminal = "kitty"
local rofi_drun = "rofi -show drun"
local rofi_window = "rofi -show window"

local colors = {
  rosewater = "#f2d5cf",
  flamingo  = "#eebebe",
  pink      = "#f4b8e4",
  mauve     = "#ca9ee6",
  red       = "#e78284",
  maroon    = "#ea999c",
  peach     = "#ef9f76",
  yellow    = "#e5c890",
  green     = "#a6d189",
  teal      = "#81c8be",
  sky       = "#99d1db",
  sapphire  = "#85c1dc",
  blue      = "#8caaee",
  lavender  = "#babbf1",
  text      = "#c6d0f5",
  subtext1  = "#b5bfe2",
  subtext0  = "#a5adce",
  overlay2  = "#949cbb",
  overlay1  = "#838ba7",
  overlay0  = "#737994",
  surface2  = "#626880",
  surface1  = "#51576d",
  surface0  = "#414559",
  base      = "#303446",
  mantle    = "#292c3c",
  crust     = "#232634",
}

------------------
--- Auto Start ---
------------------

hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm app -- waybar")
  hl.exec_cmd("uwsm app -- hyprmoncfgd")
  hl.exec_cmd("uwsm app -- rofi-polkit-agent")
  hl.exec_cmd(
    "uwsm app -- wl-paste --watch clipvault store --ignore-pattern '^<meta http-equiv=' --max-entries 50 --max-entry-age 1d")
  hl.exec_cmd("uwsm app -- wl-paste --type image --watch clipvault store --max-entries 50 --max-entry-age 1d")
  hl.exec_cmd(
    "uwsm app -- wl-paste --watch notify-send -a clipboard -h string:x-dunst-stack-tag:clipboard 'System' 'Copied to Clipboard' --expire-time=1500")
  hl.exec_cmd("uwsm app -- ags run")
  hl.exec_cmd("uwsm finalize HYPRLAND_INSTANCE_SIGNATURE")
end)

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
  output   = "",
  mode     = "preferred",
  position = "auto",
  scale    = "auto",
})

---------------------
--- LOOK AND FEEL ---
---------------------
-- https://wiki.hypr.land/Configuring/Basics/Variables/

-- https://wiki.hypr.land/Configuring/Basics/Variables/#general
hl.config({
  general = {
    gaps_in = 10,
    gaps_out = 20,
    border_size = 2,
    col = {
      inactive_border = colors.overlay0,
      active_border = { colors = { colors.lavender, colors.lavender }, angle = 45 },
      nogroup_border = colors.red,
      nogroup_border_active = colors.red,
    },
    resize_on_border = true,
    allow_tearing = false,
    layout = "scrolling",
    float_gaps = 0,
    gaps_workspaces = 0,
    no_focus_fallback = false,
    extend_border_grab_area = 15,
    hover_icon_on_border = true,
    resize_corner = 2,
    modal_parent_blocking = true,


    -- https://wiki.hyprland.org/Configuring/Basics/Variables/#snap
    snap = {
      enabled = true,
      window_gap = 10,
      monitor_gap = 10,
      border_overlap = false,
      respect_gaps = false,
    }
  },

  -- https://wiki.hyprland.org/Configuring/Basics/Variables/#decoration
  decoration = {
    rounding = 1,
    rounding_power = 2.0,
    active_opacity = 1.0,
    inactive_opacity = 0.98,
    fullscreen_opacity = 1.0,
    dim_modal = true,
    dim_inactive = true,
    dim_strength = 0.05,
    dim_special = 0.2,
    dim_around = 0.4,
    -- screen_shader = "",
    border_part_of_window = true,

    -- https://wiki.hyprland.org/Configuring/Variables/#blur
    blur = {
      enabled = true,
      size = 0,
      passes = 1,
      ignore_opacity = true,
      new_optimizations = true,
      xray = false,
      noise = 0.0117,
      contrast = 0.8916,
      brightness = 0.8172,
      vibrancy = 0.1696,
      vibrancy_darkness = 0.0,
      special = false,
      popups = false,
      popups_ignorealpha = 0.2,
      input_methods = false,
      input_methods_ignorealpha = 0.2,
    },

    -- https://wiki.hyprland.org/Configuring/Variables/#shadow
    shadow = {
      enabled = true,
      range = 5,
      render_power = 1,
      sharp = false,
      color = colors.lavender,
      color_inactive = colors.overlay0,
      offset = { 0, 0 },
      scale = 1,
    },

    -- https://wiki.hyprland.org/Configuring/Variables/#glow
    -- glow = {
    --   enabled = false,
    --   range = 10,
    --   render_power = 3,
    --   color = "",
    --   color_inactive = "",
    -- },
  },

  animations = {
    enabled = true,
    workspace_wraparound = true,
  }
})

-- https://wiki.hyprland.org/Configuring/Variables/#animations
-- Bezier curves
hl.curve("smoothOut", { type = "bezier", points = { { 0.36, 0 }, { 0.66, -0.56 } } })
hl.curve("smoothIn", { type = "bezier", points = { { 0.25, 1 }, { 0.5, 1 } } })
hl.curve("overshot", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("softSnap", { type = "bezier", points = { { 0.34, 0 }, { 0.2, 1 } } })
hl.curve("fluent", { type = "bezier", points = { { 0.0, 0.0 }, { 0.2, 1.0 } } })
hl.curve("easeInOutExpo", { type = "bezier", points = { { 0.87, 0 }, { 0.13, 1 } } })

-- Windows
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "overshot", style = "popin 80%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "overshot", style = "popin 50%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "smoothOut", style = "popin 50%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "softSnap" })
-- Layers
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "overshot", style = "slidevert" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 8, bezier = "softSnap", style = "slidevert" })
-- Fade
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "smoothOut" })
hl.animation({ leaf = "fadeSwitch", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeShadow", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeDpms", enabled = true, speed = 4, bezier = "smoothIn" })
hl.animation({ leaf = "fadeLayers", enabled = true, speed = 3, bezier = "softSnap" })
-- Workspaces
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "softSnap", style = "slidevert 100%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 5, bezier = "overshot", style = "slidefadevert 30%" })

hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 1,
    focus_fit_method = 1,
    follow_focus = true,
    follow_min_visible = 0.5,
    direction = "right",
  },
})

-- https://wiki.hyprland.org/Configuring/Variables/#misc
hl.config({
  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo   = true,
  },
})

-------------
--- INPUT ---
-------------

-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
  input = {
    kb_layout    = "us",
    kb_variant   = "",
    kb_model     = "",
    kb_options   = "",
    kb_rules     = "",

    follow_mouse = 1,

    sensitivity  = 0, -- -1.0 - 1.0, 0 means no modification.

    touchpad     = {
      natural_scroll = false,
    },
  },
})

-------------------
--- KEYBINDINGS ---
-------------------

-- See https://wiki.hyprland.org/Configuring/Keywords/
local mainMod = "ALT"

-- https://wiki.hypr.land/Configuring/Basics/Binds/ for more
-- General
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal .. " -o shell=bash"))
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(rofi_drun))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(rofi_window))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("uwsm stop"))
hl.bind(mainMod .. " + 0", hl.dsp.exec_cmd("pkill waybar && waybar &"))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("nix-rebuild-edit.sh"))
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("nix-log.sh"))
hl.bind(mainMod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("nix-rebuild.sh"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("grimblast --freeze save area - | satty -f -"))
hl.bind(mainMod .. " + m", hl.dsp.exec_cmd("kitty --class tui-rmpc rmpc"))
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("rmpc prev"))
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("rmpc next"))
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("rmpc togglepause"))
hl.bind(mainMod .. " + c", hl.dsp.exec_cmd("kitty --class tui-clipvault fzf-clipvault.sh"))

-- Switch active window
hl.bind(mainMod .. " + H", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + L", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + LEFT", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + RIGHT", hl.dsp.layout("move +col"))

-- Cycle through active window
hl.bind(mainMod .. " + mouse_up", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + mouse_down", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

-- Switch active monitor  -- TODO: focusmonitor / split-cycleworkspaces
hl.bind(mainMod .. " + CTRL + LEFT", hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + UP", hl.dsp.exec_raw("split-cycleworkspaces +1"))
hl.bind(mainMod .. " + CTRL + DOWN", hl.dsp.exec_raw("split-cycleworkspaces -1"))
hl.bind(mainMod .. " + CTRL + J", hl.dsp.exec_raw("split-cycleworkspaces +1"))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.exec_raw("split-cycleworkspaces -1"))

-- Move active window to another monitor
hl.bind(mainMod .. " + CTRL + SHIFT + LEFT", hl.dsp.window.move({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + RIGHT", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + UP", hl.dsp.exec_raw("split-movetoworkspace +1"))
hl.bind(mainMod .. " + CTRL + SHIFT + DOWN", hl.dsp.exec_raw("split-movetoworkspace -1"))
hl.bind(mainMod .. " + CTRL + SHIFT + J", hl.dsp.exec_raw("split-movetoworkspace +1"))
hl.bind(mainMod .. " + CTRL + SHIFT + K", hl.dsp.exec_raw("split-movetoworkspace -1"))

-- Adjust active window width
hl.bind(mainMod .. " + J", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + K", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + UP", hl.dsp.layout("colresize +conf"))
hl.bind(mainMod .. " + DOWN", hl.dsp.layout("colresize -conf"))
hl.bind(mainMod .. " + F", hl.dsp.layout("fit active"))
hl.bind(mainMod .. " + B", hl.dsp.layout("promote"))

-- Move active window within workspace
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + L", hl.dsp.layout("swapcol r"))
hl.bind(mainMod .. " + SHIFT + LEFT", hl.dsp.layout("swapcol l"))
hl.bind(mainMod .. " + SHIFT + RIGHT", hl.dsp.layout("swapcol r"))

-- Switch workspaces on active monitor
hl.bind(mainMod .. " + 1", hl.dsp.exec_raw("split-workspace 1"))
hl.bind(mainMod .. " + 2", hl.dsp.exec_raw("split-workspace 2"))
hl.bind(mainMod .. " + 3", hl.dsp.exec_raw("split-workspace 3"))
hl.bind(mainMod .. " + 4", hl.dsp.exec_raw("split-workspace 4"))
hl.bind(mainMod .. " + 5", hl.dsp.exec_raw("split-workspace 5"))

-- Move active window to a workspace on active monitor silently
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.exec_raw("split-movetoworkspacesilent 1"))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.exec_raw("split-movetoworkspacesilent 2"))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.exec_raw("split-movetoworkspacesilent 3"))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.exec_raw("split-movetoworkspacesilent 4"))
hl.bind(mainMod .. " + CTRL + 5", hl.dsp.exec_raw("split-movetoworkspacesilent 5"))

-- Move active window to a workspace on active monitor and focus
hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.exec_raw("split-movetoworkspace 1"))
hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.exec_raw("split-movetoworkspace 2"))
hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.exec_raw("split-movetoworkspace 3"))
hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.exec_raw("split-movetoworkspace 4"))
hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.exec_raw("split-movetoworkspace 5"))

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s 10%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"), { locked = true, repeating = true })

-- Media (locked)
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

------------------------------
--- WINDOWS AND WORKSPACES ---
------------------------------
-- # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- # See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
  name           = "windowrule-1",
  match          = { class = ".*" },
  suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland
hl.window_rule({
  name     = "windowrule-2",
  match    = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
})

hl.layer_rule({
  name        = "layerrule-rofi",
  match       = { namespace = "^(rofi)$" },
  order       = 2,
  dim_around  = true,
  blur        = true,
  blur_popups = true,
})

hl.window_rule({
  name    = "windowrule-screen-capture",
  match   = { class = "com.gabm.satty" },
  float   = true,
  no_anim = true,
})

hl.window_rule({
  name    = "windowrule-kitty-transparent",
  match   = { class = "kitty" },
  opacity = 0.95,
})

hl.window_rule({
  name  = "windowrule-tui",
  match = { class = "^(tui-.*)$" },
  float = true,
  size  = { "monitor_w*0.80", "monitor_h*0.70" },
})

hl.window_rule({
  name  = "windowrule-filechooser",
  match = { title = "^(termfilechooser)$" },
  float = true,
  size  = { "monitor_w*0.80", "monitor_h*0.70" },
})

hl.window_rule({
  name  = "windowrule-steam-float",
  match = { class = "^(steam)$" },
  float = true,
  size  = { "monitor_w*0.31", "monitor_h*0.55" },
})

hl.window_rule({
  name  = "windowrule-steam",
  match = { title = "^(Steam)$" },
  float = false,
})

hl.window_rule({
  name  = "windowrule-steam",
  match = { title = "^(Steam)$" },
  float = false,
})

hl.window_rule({
  name  = "windowrule-evolution",
  match = { title = "Inbox", class = "org.gnome.Evolution" },
  float = false,
})

hl.window_rule({
  name  = "windowrule-evolution-popup",
  match = { title = "negative:Inbox", class = "org.gnome.Evolution" },
  float = true,
  size  = { "monitor_w*0.80", "monitor_h*0.70" },
})

local fx_prev, fx_cur = nil, nil

hl.on("window.active", function(w)
  if w and w.class == "firefox" then
    local a = "address:" .. tostring(w.address)
    if a ~= fx_cur then fx_prev, fx_cur = fx_cur, a end
  end
end)

hl.on("window.title", function(w)
  if w.title and w.title:match("^Extension:") and w.class == "firefox" then
    local popup  = "address:" .. tostring(w.address)
    local parent = (fx_cur == popup) and fx_prev or fx_cur
    local mon    = hl.get_active_monitor()

    hl.dispatch(hl.dsp.window.float({ window = popup, action = "on" }))
    hl.dispatch(hl.dsp.window.resize({
      window = popup,
      x = math.floor(mon.width * 0.31),
      y = math.floor(mon.height * 0.55)
    }))
    hl.dispatch(hl.dsp.focus({ window = parent }))
    hl.dispatch(hl.dsp.focus({ window = popup }))
  end
end)

-- Focus browser when link open
hl.config({
  misc = {
    focus_on_activate = true,
  },
})
