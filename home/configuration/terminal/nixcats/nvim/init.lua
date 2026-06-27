require('config.options')
require('config.keymaps')
require('config.autocmds')

vim.o.background = "dark"
vim.cmd.colorscheme('catppuccin-frappe')

-- require("snacks").setup({ ... })
-- -- snacks keymaps ...
--
require('lze').register_handlers(require('lzextras').lsp)
require('lze').h.lsp.set_ft_fallback(function(name)
  return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes or {}
end)

vim.diagnostic.config({
  virtual_text = true,      -- show error message inline
  signs = true,             -- show signs in sign column
  underline = true,         -- underline the error
  update_in_insert = false, -- don't update while typing
  severity_sort = true,     -- sort by severity
})

require('lze').load({
  { import = "plugins.functionality.blink-cmp" },
  { import = "plugins.functionality.nvim-treesitter" },
  { import = "plugins.functionality.edgy-nvim" },
  { import = "plugins.functionality.fzf-lua" },
  { import = "plugins.functionality.conform-nvim" },

  { import = "plugins.visual.catppuccin-nvim" },
  { import = "plugins.visual.gitsigns-nvim" },
  { import = "plugins.visual.lualine-nvim" },
  { import = "plugins.visual.neo-tree-nvim" },
  { import = "plugins.visual.which-key-nvim" },

  { import = "plugins.lsp.nvim-lspconfig" },
  { import = "plugins.lsp.nixd" },
  { import = "plugins.lsp.lua-language-server" },
  { import = "plugins.lsp.vscode-langservers-extracted" },
  { import = "plugins.lsp.taplo" },
  { import = "plugins.lsp.yaml-language-server" },
  { import = "plugins.lsp.roslyn-nvim" },
  { import = "plugins.lsp.emmet-language-server" },
  { import = "plugins.lsp.typescript-language-server" },
  {
    "noice.nvim",
    event = "DeferredUIEnter", -- give it a real trigger too
    before = function(_)
      vim.cmd.packadd("nui.nvim")
    end,
    after = function(_)
      require("noice").setup({
        cmdline = {
          view = "cmdline_popup", -- centered floating cmdline instead of bottom
        },
        -- optional: also route long/normal messages away from the bottom
        messages = {
          enabled = true,
          view = "notify",
          view_error = "notify",
          view_warn = "notify",
        },
        routes = {
          {
            filter = { event = "msg_show", kind = "" },
            view = "mini", -- short ":w" type messages as a small popup instead of bottom line
          },
        },
      })
    end,
  },
})
