--- @since 26.8.15

-- Detail columns (type, size, modified) for the current pane, plus header rows with
-- labels and a dashed separator above all three panes ("File Tree", the columns, "Preview").
--
-- Setup (after full-border, since it wraps its layout):
--   require("column-header"):setup()
-- and in yazi.toml: linemode = "details"
--
-- Running the plugin (`plugin column-header`) calculates the total size of the selected
-- folders, or the hovered one, as a task; the Size column spins and counts up meanwhile.

local TYPE_W, SIZE_W, TIME_W = 10, 9, 19
local GAP = "  "
local HEADER_ROWS = 2

local LABEL = "#e5c890"
local SEP = "#626880"

local TYPES = {
  md = "markdown", json = "json", nix = "nix", yaml = "yaml", yml = "yaml", toml = "toml",
  lua = "lua", ts = "typescript", tsx = "typescript", js = "javascript", sh = "shell",
  py = "python", rs = "rust", go = "go", css = "css", scss = "scss", html = "html",
  txt = "text", lock = "lock", ron = "ron", conf = "config", sql = "sql",
  png = "image", jpg = "image", jpeg = "image", webp = "image", gif = "image", svg = "image",
  mp3 = "audio", flac = "audio", ogg = "audio", wav = "audio", m4a = "audio",
  mp4 = "video", mkv = "video", mov = "video", webm = "video",
  zip = "archive", tar = "archive", gz = "archive", xz = "archive", ["7z"] = "archive",
  pdf = "pdf", gitignore = "git", gitattributes = "git", gitmodules = "git",
}

-- Pad or cut text to a fixed number of characters (not bytes: "—", "↑" are multi-byte)
local function fit(text, width, right)
  text = tostring(text)
  local len = utf8.len(text) or #text
  if len > width then
    text = text:sub(1, utf8.offset(text, width) - 1) .. "…"
    len = width
  end
  local pad = string.rep(" ", width - len)
  return right and pad .. text or text .. pad
end

local function file_type(file)
  if file.cha.is_link then
    return "symlink"
  elseif file.cha.is_dir then
    return "folder"
  end
  local name = file.name:lower()
  local ext = name:match("%.([^.]+)$") or name:match("^%.(.+)$")
  return ext and (TYPES[ext] or ext) or "file"
end

local UNITS = { "B", "KB", "MB", "GB", "TB" }
local SPINNER = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

-- "512 B", "4.2 KB", "38 MB": one decimal under 10, whole numbers above
local function readable(size)
  local unit = 1
  while size >= 1024 and unit < #UNITS do
    size = size / 1024
    unit = unit + 1
  end
  local num = (unit == 1 or size >= 10) and string.format("%d", math.floor(size + 0.5))
    or string.format("%.1f", size)
  return num .. " " .. UNITS[unit]
end

-- Title of the task calculating a folder, also used to spot when it was cancelled
local function task_title(key)
  return "Size of " .. key
end

-- A folder whose size task was seen in the task list, then left it without the plugin
-- finishing it, was cancelled (cancelling stops the plugin outright, so it can't report that
-- itself). A new task takes a moment to show up, so not having seen it yet doesn't count.
local function was_cancelled(st, key)
  local title = task_title(key)
  for _, snap in ipairs(cx.tasks.snaps) do
    if snap.title == title then
      st.seen[key] = true
      return false
    end
  end
  return st.seen[key] == true
end

-- Folders being calculated show a spinner and the running total; cancelled ones ERROR until
-- calculated again. A no-break space follows the symbols: kitty stretches a symbol over a
-- following plain space, and yazi then leaves that half behind on screen
local function file_size(st, file)
  local key = tostring(file.url)
  if st.busy[key] and was_cancelled(st, key) then
    st.busy[key], st.seen[key], st.cancelled[key] = nil, nil, true
  end
  if st.cancelled[key] then
    return "ERROR"
  end
  local busy = st.busy[key]
  if busy then
    return SPINNER[st.frame] .. "\u{a0}" .. readable(busy)
  end
  local size = st.sizes[key] or file:size()
  return size and readable(size) or "—"
end

local function file_time(file)
  local time = math.floor(file.cha.mtime or 0)
  if time == 0 then
    return "—"
  end
  return os.date("%Y-%m-%d %I:%M %p", time)
end

-- Arrow next to the column the current pane is sorted by
local function sorted(column)
  local pref = cx.active.pref
  local by = {
    alphabetical = "name", natural = "name", extension = "type", size = "size", mtime = "modified",
  }
  if by[pref.sort_by] ~= column then
    return ""
  end
  return pref.sort_reverse and " ↓" or " ↑"
end

local function dashes(area)
  return ui.Text(ui.Line(ui.Span(string.rep("╌", area.w)):fg(SEP)))
    :area(ui.Rect { x = area.x, y = area.y + 1, w = area.w, h = 1 })
end

local function label(area, left, right)
  local items = { ui.Text(ui.Line(ui.Span(left):fg(LABEL))):area(area), dashes(area) }
  if right and right ~= "" then
    items[#items + 1] = ui.Text(ui.Line(ui.Span(right .. " "):fg(SEP))):area(area):align(ui.Align.RIGHT)
  end
  return items
end

local function header(area)
  local right = table.concat({
    " ",
    fit("Type" .. sorted("type"), TYPE_W, true),
    GAP,
    fit("Size" .. sorted("size"), SIZE_W, true),
    GAP,
    fit("Modified" .. sorted("modified"), TIME_W, true),
    " ",
  })
  return {
    ui.Text(ui.Line(ui.Span("   Name" .. sorted("name")):fg(LABEL))):area(area),
    ui.Text(ui.Line(ui.Span(right):fg(LABEL))):area(area):align(ui.Align.RIGHT),
    dashes(area),
  }
end

local function setup(st, opts)
  st.busy, st.seen, st.cancelled, st.sizes, st.frame = {}, {}, {}, {}, 1

  function Linemode:details()
    local f = self._file
    local size, color = file_size(st, f)
    local size_span = ui.Span(fit(size, SIZE_W, true))
    return ui.Line({
      ui.Span(fit(file_type(f), TYPE_W, true) .. GAP),
      color and size_span:fg(color) or size_span,
      ui.Span(GAP .. fit(file_time(f), TIME_W, true)),
    })
  end

  -- Take the header rows from the top of the current pane, so yazi sizes the file list
  -- to the remaining rows instead of drawing the header over files
  local function below_header(r)
    return ui.Rect { x = r.x, y = r.y + HEADER_ROWS, w = r.w, h = math.max(r.h - HEADER_ROWS, 0) }
  end

  local old_build = Tab.build
  Tab.build = function(self, ...)
    old_build(self, ...)
    local panes = { parent = Parent, current = Current, preview = Preview }
    for i, child in ipairs(self._children) do
      local pane = panes[child._id]
      if pane then
        local a = child._area
        local top = ui.Rect { x = a.x, y = a.y, w = a.w, h = HEADER_ROWS }
        self._children[i] = pane:new(below_header(a), self._tab)
        local hovered = self._tab.current.hovered
        local labels = child._id == "current" and header(top)
          or child._id == "parent" and label(top, " File Tree")
          or label(top, " Preview", hovered and hovered.name or "")
        self._base = ya.list_merge(self._base or {}, labels)
      elseif child._id == "markers" then
        -- The marker bars (selected/yanked files) are placed from the pane layout, so shift them too
        local c = self._chunks
        self._children[i] = Markers:new({ below_header(c[1]), below_header(c[2]), c[3] }, self._tab)
      end
    end
  end
end

-- Selected folders, or the hovered one, that aren't already being calculated
local start = ya.sync(function(st)
  local urls = {}
  local function add(url)
    local key = tostring(url)
    if not st.busy[key] then
      st.busy[key], st.cancelled[key] = 0, nil
      urls[#urls + 1] = url
    end
  end
  local files = cx.active.current.files
  for i = 1, #files do
    local f = files[i]
    if f.cha.is_dir and f:is_selected() then
      add(f.url)
    end
  end
  local h = cx.active.current.hovered
  if #urls == 0 and h and h.cha.is_dir then
    add(h.url)
  end
  return urls
end)

-- Only plain values cross into these sync blocks (folders by their path string), and a
-- failed redraw only costs a frame of the spinner
local function redraw()
  pcall(ui.render)
end

local progress = ya.sync(function(st, key, size)
  st.busy[key] = size
  st.frame = (st.frame or 1) % #SPINNER + 1
  redraw()
end)

local finish = ya.sync(function(st, key, size)
  st.busy[key], st.seen[key], st.sizes[key] = nil, nil, size
  redraw()
end)

-- Forget the sizes and cancel marks (ERROR) of the current folder's entries (Shift+R)
local clear = ya.sync(function(st)
  local cwd = tostring(cx.active.current.cwd)
  for _, t in ipairs({ st.sizes, st.cancelled }) do
    for key in pairs(t) do
      if key:match("^(.*)/[^/]+$") == cwd then
        t[key] = nil
      end
    end
  end
  redraw()
end)

local function measure(url)
  local it = fs.calc_size(url)
  if not it then
    error("can't read it")
  end
  local size, last = 0, 0
  while true do
    local next, now = it:recv(), ya.time()
    if not next then
      return size
    end
    size = size + next
    if now >= last + 0.1 then
      last = now
      progress(tostring(url), size)
    end
  end
end

local function calc(url)
  local key = tostring(url)
  local name = url.name or key
  local task = ya.task("custom", { pool = "plugin", scope = rt.scope() }):name(task_title(key)):spawn()
  if not task:acquire() then
    return finish(tostring(url))
  end

  -- Whatever goes wrong, clear the spinner and end the task, so neither is left running.
  -- The size is kept by this plugin rather than on yazi's file, so Shift+R can forget it.
  local ok, size = pcall(measure, url)
  finish(key, ok and size or nil)

  if not ok then
    ya.notify { title = "Folder size", content = name .. ": " .. tostring(size), timeout = 10, level = "error" }
    return task:fail(tostring(size))
  end
  task:succeed {}
  ya.notify { title = "Folder size", content = name .. ": " .. readable(size), timeout = 5 }
end

local function entry(_, job)
  if job.args[1] == "clear" then
    return clear()
  end
  for _, url in ipairs(start()) do
    calc(url)
  end
end

return { setup = setup, entry = entry }
