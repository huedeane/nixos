--- @since 26.8.15

-- Detail columns (type, size, modified) for the current pane, plus header rows with
-- labels and a dashed separator above all three panes ("File Tree", the columns, "Preview").
--
-- Setup (after full-border, since it wraps its layout):
--   require("column-header"):setup()
-- and in yazi.toml: linemode = "details"

local TYPE_W, SIZE_W, TIME_W = 10, 6, 19
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

local function file_size(file)
  local size = file:size()
  return size and ya.readable_size(size) or "—"
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

local function setup(_, opts)
  function Linemode:details()
    local f = self._file
    return table.concat({
      fit(file_type(f), TYPE_W, true),
      GAP,
      fit(file_size(f), SIZE_W, true),
      GAP,
      fit(file_time(f), TIME_W, true),
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

return { setup = setup }
