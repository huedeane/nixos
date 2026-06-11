-- Apply style
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    require("config.highlights").setup()
  end,
})

-- Close edgy first before close window
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    require("edgy").close()
  end,
})

-- Hide cursor in neo-tree
local function update_cursor()
  if vim.bo.filetype == "neo-tree" then
    io.write("\27[?25l")
  else
    io.write("\27[?25h")
  end
end

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  callback = update_cursor,
})

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(update_cursor, 100)
  end,
})

