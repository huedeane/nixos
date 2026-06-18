local set_command_mode = ya.sync(function(_, value)
	COMMAND_MODE = value
end)

local function entry()
	set_command_mode(true)

	local value, event = ya.input({
		title = "Command:",
		position = { "top-center", y = 1, w = 50 },
	})

	set_command_mode(false)

	if event == 1 and value ~= "" then
		ya.emit("shell", { value, interactive = false })
	end
end

return { entry = entry }
