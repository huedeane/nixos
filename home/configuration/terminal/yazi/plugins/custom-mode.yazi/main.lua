local set_mode = ya.sync(function(_, value)
  CUSTOM_MODE = value
end)

local function entry(_, args)
  set_mode("command")

  local argsList = {}
  for w in args.args[1]:gmatch("%S+") do
    argsList[#argsList + 1] = w
  end

  local cmd = argsList[1]
  local cmd_arg = table.concat(argsList, " ", 2)

  local title
  if cmd == "shell" and cmd_arg == "--block --interactive" then
    title = "Shell (block)"
  elseif cmd == "shell" then
    title = "Shell"
  else
    title = cmd
  end

  local value, event = ya.input({
    title = "─ " .. title .. " ",
    pos = { "center", y = 0, w = 50 },
    value = "",
  })

  set_mode(nil)

  if event == 1 and value ~= "" then
    if cmd == "shell" and cmd_arg == "--block --interactive" then
      ya.emit("shell", { block = true, interactive = false, value })
    elseif cmd == "shell" then
      ya.emit("shell", { block = false, interactive = false, value })
    end
  end
end

return { entry = entry }
