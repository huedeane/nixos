local M = {}

function M.keymap(specs)
  for _, s in ipairs(specs) do
    vim.keymap.set(s[1], s[2], s[3], {
      desc = s.hide and "which_key_ignore" or s.desc,
    })
  end
end

return M
