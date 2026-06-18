th.git = th.git or {}

-- Git Style
th.git.modified = ui.Style():fg("#e5c890")
th.git.added = ui.Style():fg("#a6d189")
th.git.untracked = ui.Style():fg("#e78284")
th.git.ignored = ui.Style():fg("black")
th.git.deleted = ui.Style():fg("black")
th.git.updated = ui.Style():fg("#a6d189")

-- Status Sign
th.git.modified_sign = "M"
th.git.added_sign = "A"
th.git.untracked_sign = "+"
th.git.ignored_sign = ""
th.git.deleted_sign = "?"
th.git.updated_sign = "U"

local mode_colors = {
  NORMAL  = "#babbf1",
  SELECT  = "#ca9ee6",
  UNSET   = "#ca9ee6",
  COMMAND = "#ef9f76",
}

-- Show symlink in status bar
Status:children_add(function(self)
  local h = self._current.hovered
  if h and h.link_to then
    return " -> " .. tostring(h.link_to)
  else
    return ""
  end
end, 3300, Status.LEFT)

-- Show username and hostname in header
Header:children_add(function(self)
  if ya.target_family() ~= "unix" then
    return ""
  end

  return ui.Span(ya.user_name() .. "@" .. ya.host_name() .. ": "):fg("#babbf1")
end, 500, Header.LEFT)

-- Override status mode to return full string
function Status:mode()
  local mode = (CUSTOM_MODE or tostring(self._tab.mode)):upper()
  local style = self:style()
  local color = mode_colors[mode] or "#000000"

  if mode == "SELECT" then
    mode = "VISUAL"
  end

  return ui.Line({
    ui.Span(th.status.sep_left.open):fg(color):bg("reset"),
    ui.Span(" " .. mode .. " "):style(style.main),
    ui.Span(th.status.sep_left.close):fg(color):bg("#414559"),
  })
end

function Status:style()
  local mode = (CUSTOM_MODE or tostring(self._tab.mode)):upper()
  local color = mode_colors[mode] or "#000000"
  return {
    main = ui.Style():bg(color):fg("#303446"):bold(),
    alt  = ui.Style():fg(color):bg("#414559"),
  }
end

local function git_branch(dir)
  while dir and dir ~= "" do
    local f = io.open(dir .. "/.git/HEAD", "r")
    if f then
      local line = f:read("l")
      f:close()
      -- "ref: refs/heads/main" -> "main"; detached -> short hash
      return line:match("ref: refs/heads/(.+)") or line:sub(1, 7)
    end
    local parent = dir:match("(.+)/[^/]+$")
    if parent == dir then break end
    dir = parent
  end
  return nil
end

Status:children_add(function(self)
  local mode = (CUSTOM_MODE or tostring(self._tab.mode)):upper()
  local color = mode_colors[mode] or "#000000"
  local cwd = tostring(cx.active.current.cwd)
  local branch = git_branch(cwd)
  if not branch then return ui.Line({}) end
  return ui.Line({ ui.Span("  " .. branch .. " "):fg(color):bg("#414559") })
end, 1000, Status.LEFT)

Status:children_add(function(self)
  local mode = (CUSTOM_MODE or tostring(self._tab.mode)):upper()
  local color = mode_colors[mode] or "#000000"

  local h = self._tab.current.hovered
  if not h then return ui.Line({}) end

  local kind
  if h.cha.is_dir then
    kind = "dir"
  elseif h.cha.is_link then
    kind = "link"
  else
    kind = h.name:match("%.([^.]+)$") or "file"  -- extension, or "file" if none
  end

  return ui.Line({ ui.Span("  " .. kind .. ""):fg(color):bg("#292c3c") })
end, 1100, Status.RIGHT)

require("git"):setup()
require("full-border"):setup({
  type = ui.Border.PLAIN,
})
