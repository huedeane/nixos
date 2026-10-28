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

-- Compile SCSS to CSS on save (needs `sass`/dart-sass on PATH)
-- Saving a partial (`_name.scss`) recompiles the entry files (non-`_` .scss)
-- in the same directory instead, since partials are only meant to be @use'd.
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.scss",
  callback = function(args)
    if vim.fn.executable("sass") == 0 then
      return
    end
    local input = vim.fn.fnamemodify(args.file, ":p")
    local inputs = { input }
    if vim.fn.fnamemodify(input, ":t"):sub(1, 1) == "_" then
      inputs = vim.tbl_filter(function(f)
        return vim.fn.fnamemodify(f, ":t"):sub(1, 1) ~= "_"
      end, vim.fn.glob(vim.fn.fnamemodify(input, ":h") .. "/*.scss", false, true))
    end
    for _, file in ipairs(inputs) do
      vim.system(
        { "sass", "--no-source-map", file, (file:gsub("%.scss$", ".css")) },
        { text = true },
        function(result)
          if result.code ~= 0 then
            vim.schedule(function()
              vim.notify("sass: " .. (result.stderr or "compile failed"), vim.log.levels.ERROR)
            end)
          end
        end
      )
    end
  end,
})

-- New buffer on directory start
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
