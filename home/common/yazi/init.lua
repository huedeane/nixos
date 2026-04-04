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
	local mode = tostring(self._tab.mode):upper()

	local style = self:style()
	return ui.Line({
		ui.Span(th.status.sep_left.open):fg("#babbf1"):bg("reset"),
		ui.Span(" " .. mode .. " "):style(style.main),
		ui.Span(th.status.sep_left.close):fg("#babbf1"):bg("#414559"),
	})
end

require("git"):setup()
require("full-border"):setup({
	type = ui.Border.PLAIN,
})
