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
vim.api.nvim_set_hl(0, "HiddenCursor", { blend = 100, nocombine = true })

local saved_guicursor = vim.o.guicursor

vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
  callback = function()
    if vim.bo.filetype == "neo-tree" then
      vim.o.guicursor = "a:HiddenCursor/HiddenCursor"
    else
      vim.o.guicursor = saved_guicursor
    end
  end,
})

-- Evoke callback for kitty to resize
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    io.write("\x1b]723;nvim-enter\x07")
    io.flush()
  end,
})

vim.api.nvim_create_autocmd("VimLeave", {
  callback = function()
    io.write("\x1b]723;nvim-leave\x07")
    io.flush()
  end,
})

-- autocmds.lua: just the cleanup, no plugin dependency
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.fn.isdirectory(vim.api.nvim_buf_get_name(buf)) == 1 then
      vim.cmd("enew")
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end,
})
