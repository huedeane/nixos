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
  virtual_text = true,     -- show error message inline
  signs = true,            -- show signs in sign column
  underline = true,        -- underline the error
  update_in_insert = false, -- don't update while typing
  severity_sort = true,    -- sort by severity
})

require('lze').load({
  { import = "plugins.functionality.blink-cmp" },
  { import = "plugins.functionality.nvim-treesitter" },
  { import = "plugins.functionality.edgy-nvim" },

  { import = "plugins.visual.catppuccin-nvim" },
  { import = "plugins.visual.gitsigns-nvim" },
  { import = "plugins.visual.lualine-nvim" },
  { import = "plugins.visual.neo-tree-nvim" },

  { import = "plugins.lsp.nvim-lspconfig" },
  { import = "plugins.lsp.nixd" },
  { import = "plugins.lsp.lua-language-server" },
  { import = "plugins.lsp.vscode-langservers-extracted" },
  { import = "plugins.lsp.omnisharp-roslyn" },
  { import = "plugins.lsp.taplo" },
  { import = "plugins.lsp.yaml-language-server" },
})
