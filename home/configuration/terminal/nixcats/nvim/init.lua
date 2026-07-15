require('config.options')
require('config.keymaps')
require('config.autocmds')

vim.cmd.colorscheme('catppuccin-frappe')

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
  { import = "plugins.functionality.conform-nvim" },
  { import = "plugins.functionality.fzf-lua" },
  { import = "plugins.functionality.nvim-treesitter" },

  { import = "plugins.visual.catppuccin-nvim" },
  { import = "plugins.visual.edgy-nvim" },
  { import = "plugins.visual.gitsigns-nvim" },
  { import = "plugins.visual.lualine-nvim" },
  { import = "plugins.visual.neo-tree-nvim" },
  { import = "plugins.visual.noice-nvim" },
  { import = "plugins.visual.toggleterm-nvim" },
  { import = "plugins.visual.which-key-nvim" },
  { import = "plugins.visual.statuscol-nvim" },
  { import = "plugins.visual.indent-blankline-nvim" },
  { import = "plugins.visual.nvim-navic" },
  { import = "plugins.visual.nvim-navbuddy" },

  { import = "plugins.lsp.emmet-language-server" },
  { import = "plugins.lsp.lua-language-server" },
  { import = "plugins.lsp.nvim-lspconfig" },
  { import = "plugins.lsp.nixd" },
  { import = "plugins.lsp.roslyn-nvim" },
  { import = "plugins.lsp.taplo" },
  { import = "plugins.lsp.typescript-language-server" },
  { import = "plugins.lsp.vscode-langservers-extracted" },
  { import = "plugins.lsp.yaml-language-server" },
})
