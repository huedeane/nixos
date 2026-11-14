---@diagnostic disable: undefined-global
require("smw")
require("monitors")

-- https://wiki.hyprland.org/Configuring/
-----------------
--- Variables ---
-----------------

local terminal = "kitty"
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
  hl.exec_cmd("uwsm app -- hyprmoncfgd")
  hl.exec_cmd("uwsm app -- rofi-polkit-agent")
  hl.exec_cmd(
    "uwsm app -- wl-paste --watch clipvault store --ignore-pattern '^<meta http-equiv=' --max-entries 50 --max-entry-age 1d")
  hl.exec_cmd("uwsm app -- wl-paste --type image --watch clipvault store --max-entries 50 --max-entry-age 1d")
  hl.exec_cmd("uwsm app -- clip-notify.sh")
  hl.exec_cmd("uwsm app -- ags run")
  hl.exec_cmd("uwsm finalize HYPRLAND_INSTANCE_SIGNATURE")
  hl.exec_cmd("uwsm app -- ags-reload.sh")
  -- Fallback if the ags startup fade never starts hyprpaper
  hl.exec_cmd("sh -c 'sleep 5 && systemctl --user start hyprpaper.service'")
end)

-- Blank cursor theme until the ags startup fade calls show_startup_cursor() (top level so it survives reloads)
do
  local sig = os.getenv("HYPRLAND_INSTANCE_SIGNATURE") or ""
  local marker = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-startup-cursor-" .. sig
  local remaining = 12 - (os.time() - (tonumber(sig:match("_(%d+)_%d+$")) or os.time()))
  local hypr_theme = os.getenv("STARTUP_HYPRCURSOR_THEME") or os.getenv("HYPRCURSOR_THEME") or "default"
  local x_theme = os.getenv("STARTUP_XCURSOR_THEME") or os.getenv("XCURSOR_THEME") or "default"

  function show_startup_cursor()
    local f = io.open(marker, "w"); if f then f:close() end
    hl.env("HYPRCURSOR_THEME", hypr_theme)
    hl.env("XCURSOR_THEME", x_theme)
    hl.config({ cursor = { invisible = false, enable_hyprcursor = true } })
    hl.exec_cmd("hyprctl setcursor " .. hypr_theme .. " " .. (os.getenv("HYPRCURSOR_SIZE") or "24"))
    -- Hyprland only hands XWayland its cursor when the server starts (still blank then), so reset the X root cursor
    hl.exec_cmd("XCURSOR_THEME=" .. x_theme .. " xsetroot -cursor_name left_ptr")
    -- uwsm finalize already exported the blank themes to systemd/dbus; push the real ones so launched apps inherit them
    hl.exec_cmd("dbus-update-activation-environment --systemd HYPRCURSOR_THEME=" .. hypr_theme .. " XCURSOR_THEME=" .. x_theme)
  end

  local file = io.open(marker, "r")
  if file then
    file:close()
  elseif remaining > 0 then
    hl.env("STARTUP_HYPRCURSOR_THEME", hypr_theme)
    hl.env("STARTUP_XCURSOR_THEME", x_theme)
    hl.env("HYPRCURSOR_THEME", "startup-blank-cursor")
    hl.env("XCURSOR_THEME", "startup-blank-cursor")
    hl.config({ cursor = { invisible = true, enable_hyprcursor = false } })
    local timer
    timer = hl.timer(function()
      show_startup_cursor()
      timer:set_enabled(false)
    end, { timeout = remaining * 1000, type = "repeat" })
  end
end


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
    gaps_out = { top = 20, right = 40, bottom = 20, left = 40 },
    border_size = 3,
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
    rounding = 10,
    rounding_power = 4.0,
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
      enabled = false,
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

-- https://wiki.hypr.land/Configuring/Layouts/Scrolling-Layout/#config
hl.config({
  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 1,
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
    disable_splash_rendering = true,
    -- Black until the startup fade overlay maps, matching SDDM's fade-out
    background_color        = "#000000",
  },
})

-------------
--- INPUT ---
-------------

-- https://wiki.hyprland.org/Configuring/Variables/#input
hl.config({
  input = {
    kb_layout     = "us",
    kb_variant    = "",
    kb_model      = "",
    kb_options    = "",
    kb_rules      = "",

    follow_mouse  = 2,
    mouse_refocus = false,

    sensitivity   = 0,

    touchpad      = {
      natural_scroll = false,
    },
  },
})

-------------------
--- KEYBINDINGS ---
-------------------

-- See https://wiki.hyprland.org/Configuring/Keywords/
local mainMod = "ALT"

-- https://wiki.hypr.land/Configuring/Basics/Binds/
-- General

-- Terminal w/Tmux
hl.bind(mainMod .. " + T", function()
  local window = hl.get_windows({ class = terminal })[1]
  if window then
    hl.dispatch(hl.dsp.focus({ window = "address:" .. tostring(window.address) }))
  else
    hl.dispatch(hl.dsp.exec_cmd(terminal))
  end
end)
-- Terminal
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd(terminal .. " -o shell=bash"))
-- App Launcher
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd("ags request launcher"))
-- Notification History
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("ags request notifications"))
-- Window Manager
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd(rofi_window))
-- Log Out
hl.bind(mainMod .. " + CTRL + SHIFT + Escape", hl.dsp.exec_cmd("uwsm stop"))
-- Nix Rebuild (Edit Mode)
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("nix-rebuild-edit.sh"))
-- Nix Rebuild
hl.bind(mainMod .. " + CTRL + SHIFT + R", hl.dsp.exec_cmd("nix-rebuild.sh"))
-- Nix Build Log
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("nix-log.sh"))
-- Close Window
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
-- Kill Window
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.kill())
-- Toggle Window Float
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
-- Screenshoot
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("grimblast --freeze save area - | satty -f -"))
-- Screen Capture
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd("screen-gif.sh"))
-- Music Player
hl.bind(mainMod .. " + M", function()
  local rmpc = hl.get_windows({ class = "tui-rmpc" })[1]
  if rmpc then
    hl.dispatch(hl.dsp.window.close({ window = "address:" .. tostring(rmpc.address) }))
  else
    hl.dispatch(hl.dsp.exec_cmd("kitty --class tui-rmpc -o confirm_os_window_close=0 rmpc"))
  end
end)
-- Music Player Command Previous
hl.bind(mainMod .. " + comma", hl.dsp.exec_cmd("rmpc prev"))
-- Music Player Command Next
hl.bind(mainMod .. " + period", hl.dsp.exec_cmd("rmpc next"))
-- Music Player Command Pause
hl.bind(mainMod .. " + slash", hl.dsp.exec_cmd("rmpc togglepause"))
-- Music Player Volume Down / Up (hold to repeat)
hl.bind(mainMod .. " + SHIFT + comma", hl.dsp.exec_cmd("rmpc volume -5"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + period", hl.dsp.exec_cmd("rmpc volume +5"), { repeating = true })
-- Music Player Seek Back / Forward 5s (hold to repeat)
hl.bind(mainMod .. " + SHIFT + CTRL + comma", hl.dsp.exec_cmd("rmpc seek -5"), { repeating = true })
hl.bind(mainMod .. " + SHIFT + CTRL + period", hl.dsp.exec_cmd("rmpc seek +5"), { repeating = true })
-- Clipboard History
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("kitty --class tui-clipvault fzf-clipvault.sh"))

-- Switch active window
hl.bind(mainMod .. " + H", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + L", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + LEFT", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + RIGHT", hl.dsp.layout("move +col"))

-- Cycle through active window
hl.bind(mainMod .. " + mouse_up", hl.dsp.layout("move -col"))
hl.bind(mainMod .. " + mouse_down", hl.dsp.layout("move +col"))
hl.bind(mainMod .. " + Tab", hl.dsp.window.cycle_next())

-- Switch active monitor
hl.bind(mainMod .. " + CTRL + LEFT", hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + RIGHT", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.focus({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + DOWN", smw.cycle_workspaces("+1"))
hl.bind(mainMod .. " + CTRL + UP", smw.cycle_workspaces("-1"))
hl.bind(mainMod .. " + CTRL + J", smw.cycle_workspaces("+1"))
hl.bind(mainMod .. " + CTRL + K", smw.cycle_workspaces("-1"))

-- Move active window to another monitor
hl.bind(mainMod .. " + CTRL + SHIFT + LEFT", hl.dsp.window.move({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + RIGHT", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + H", hl.dsp.window.move({ monitor = "-1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + L", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + DOWN", smw.move_to_workspace_silent("+1"))
hl.bind(mainMod .. " + CTRL + SHIFT + UP", smw.move_to_workspace_silent("-1"))
hl.bind(mainMod .. " + CTRL + SHIFT + J", smw.move_to_workspace_silent("+1"))
hl.bind(mainMod .. " + CTRL + SHIFT + K", smw.move_to_workspace_silent("-1"))

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

for i = 1, smw.get_amount_of_workspaces() do
  local n = tostring(i)

  -- Switch workspaces on active monitor
  hl.bind(mainMod .. " + " .. n, smw.workspace(n))
  -- Move active window to a workspace on active monitor silently
  hl.bind(mainMod .. " + CTRL + " .. n, smw.move_to_workspace_silent(n))
  -- Move active window to a workspace on active monitor and focus
  hl.bind(mainMod .. " + SHIFT + " .. n, smw.move_to_workspace(n))
end

-- Special workspace (scratchpad)
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic", silent = true, follow = false }))
hl.bind(mainMod .. " + CTRL + SHIFT + S", function()
  hl.dispatch(hl.dsp.window.move({ workspace = hl.get_active_workspace().id, silent = true, follow = false }))
end)

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Volume / brightness (locked + repeating)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"),
  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"),
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

-- Super+Shift+F: an open ags popup (launcher, notifications) wins, otherwise focus the
-- topmost floating window on this monitor (repeat to cycle). Either way the cursor is parked
-- in its middle, hidden until the mouse actually moves
local cursor_timer = nil

-- Global so ags can call it through `hyprctl dispatch` for its popups
function park_cursor(center)
  hl.config({ cursor = { invisible = true } })
  hl.dispatch(hl.dsp.cursor.move(center))

  if cursor_timer then cursor_timer:set_enabled(false) end
  cursor_timer = hl.timer(function()
    local pos = hl.get_cursor_pos()
    if pos and (math.abs(pos.x - center.x) > 1 or math.abs(pos.y - center.y) > 1) then
      hl.config({ cursor = { invisible = false } })
      cursor_timer:set_enabled(false)
    end
  end, { timeout = 100, type = "repeat" })
end

local function floating_windows(monitor)
  local windows = {}
  for _, w in ipairs(hl.get_windows({ floating = true, mapped = true })) do
    local on_screen = w.workspace and w.workspace.id == monitor.active_workspace.id
    local pinned_here = w.pinned and w.monitor and w.monitor.id == monitor.id
    if not w.hidden and (on_screen or pinned_here) then windows[#windows + 1] = w end
  end
  -- Most recently focused first; focusing raises a float, so that's also the topmost
  table.sort(windows, function(a, b) return a.focus_history_id < b.focus_history_id end)
  return windows
end

-- Global so ags can fall back to it when no popup is open
function focus_topmost_float()
  local monitor = hl.get_active_monitor()
  if not monitor or not monitor.active_workspace then return end
  local windows = floating_windows(monitor)
  if #windows == 0 then return end

  -- Already on the topmost float: go to the one focused longest ago, which walks through
  -- all of them on repeated presses
  local active = hl.get_active_window()
  local target = windows[1]
  if active and target.address == active.address then target = windows[#windows] end

  hl.dispatch(hl.dsp.focus({ window = "address:" .. target.address }))
  park_cursor({ x = target.at.x + target.size.x / 2, y = target.at.y + target.size.y / 2 })
end

-- ags answers for its popups and calls focus_topmost_float itself when none is open; the
-- fallback covers ags not running
hl.bind(mainMod .. " + SHIFT + F",
  hl.dsp.exec_cmd("ags request focus-popup || hyprctl dispatch 'function() focus_topmost_float() end'"))

-- Screen recording: only active while screen-gif.sh is recording, keys still reach apps
local function recording()
  local pidfile = io.open((os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/screen-gif/pid")
  if not pidfile then return false end
  local pid = pidfile:read("*l")
  pidfile:close()
  local comm = pid and io.open("/proc/" .. pid .. "/comm")
  if not comm then return false end
  local name = comm:read("*l")
  comm:close()
  return name == "wf-recorder"
end

hl.bind("CTRL + S", function()
  if recording() then hl.dispatch(hl.dsp.exec_cmd("screen-gif.sh save")) end
end, { non_consuming = true })
hl.bind("CTRL + C", function()
  if recording() then hl.dispatch(hl.dsp.exec_cmd("screen-gif.sh copy")) end
end, { non_consuming = true })
hl.bind("Escape", function()
  if recording() then hl.dispatch(hl.dsp.exec_cmd("screen-gif.sh cancel")) end
  hl.dispatch(hl.dsp.exec_cmd("ags request close-popups"))
end, { non_consuming = true })

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
  name    = "layerrule-window-close",
  match   = { namespace = "^(window-close)$" },
  no_anim = true,
})

hl.layer_rule({
  name    = "layerrule-record-border",
  match   = { namespace = "^(record-border)$" },
  no_anim = true,
})

hl.layer_rule({
  name    = "layerrule-startup-fade",
  match   = { namespace = "^(startup-fade)$" },
  no_anim = true,
})

hl.layer_rule({
  name      = "layerrule-hyprpaper",
  match     = { namespace = "^(hyprpaper)$" },
  animation = "fade",
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
  name  = "windowrule-screen-capture",
  match = { class = "com.gabm.satty" },
  float = true,
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
  match = { initial_title = "Mail", class = "org.gnome.Evolution" },
  float = false,
})

hl.window_rule({
  name  = "windowrule-evolution-popup",
  match = { initial_title = "negative:Mail", class = "org.gnome.Evolution" },
  float = true,
  size  = { "monitor_w*0.80", "monitor_h*0.70" },
})

-- The VM console grabs the keyboard via shortcuts-inhibit; ignore it so Hyprland binds still win
hl.window_rule({
  name                 = "windowrule-virt-manager",
  match                = { class = "^(\\.?virt-manager.*)$" },
  no_shortcuts_inhibit = true,
})

hl.window_rule({
  name  = "windowrule-firefox-connection",
  match = { initial_title = "Incoming Connection", initial_class = "firefox" },
  float = true,
  size  = { "monitor_w*0.31", "monitor_h*0.55" },
})

-- Float firefox extension and Google sign-in popups. They open titled "Mozilla Firefox", so
-- float every new firefox window up front (keeps it out of the scrolling columns), then once
-- the real title arrives keep popups floating and send anything else back to tiling
-- https://wiki.hypr.land/configuring/code-snippets/#float-browsers-extension-windows

-- Last two active firefox windows, so a popup knows which window opened it
local fx_prev, fx_cur = nil, nil

hl.on("window.active", function(w)
  if w and w.class == "firefox" then
    local a = "address:" .. tostring(w.address)
    if a ~= fx_cur then fx_prev, fx_cur = fx_cur, a end
  end
end)

hl.on("window.open", function(w)
  if w.class ~= "firefox" then return end
  if w.initial_title ~= "Mozilla Firefox" then return end
  if #hl.get_windows({ class = "firefox" }) <= 1 then return end

  local popup = "address:" .. tostring(w.address)
  local parent = (fx_cur == popup) and fx_prev or fx_cur

  -- Focusing the parent scrolls the columns back to it (the new window shifted them),
  -- then the floating popup gets focus on top without moving the view again
  local refocus = function()
    if parent then hl.dispatch(hl.dsp.focus({ window = parent })) end
    hl.dispatch(hl.dsp.focus({ window = popup }))
  end

  hl.dispatch(hl.dsp.window.float({ action = "set", window = w }))
  refocus()

  local sub
  sub = hl.on("window.title", function(tw)
    if tw.address ~= w.address then return end
    if tw.title == ""
        or tw.title == "Mozilla Firefox"
        or tw.title == "about:blank"
        or tw.title:match("^about:.*Mozilla Firefox$") then
      return
    end

    sub:remove()

    -- Extension popups and Google's sign-in popup stay floating
    if tw.title:match("^Extension:") or tw.title:match("^Sign in %- Google Accounts") then
      local mon = hl.get_active_monitor()
      hl.dispatch(hl.dsp.window.resize({
        window = tw,
        x = math.floor(mon.width * 0.31),
        y = math.floor(mon.height * 0.55),
      }))
      hl.dispatch(hl.dsp.window.center({ window = tw }))
      refocus()
    else
      hl.dispatch(hl.dsp.window.float({ action = "unset", window = tw }))
    end
  end)
end)

-- Focus browser when link open
hl.config({
  misc = {
    focus_on_activate = true,
  },
})

---@format disable-next

-- Added by hyprmoncfg: its generated monitor rules load last, so nothing before this can override the applied layout.
do local path = (os.getenv("XDG_CONFIG_HOME") or os.getenv("HOME") .. "/.config") .. "/hypr/hyprmoncfg-monitors.lua"; local file = io.open(path, "r"); if file then file:close(); dofile(path) end end
