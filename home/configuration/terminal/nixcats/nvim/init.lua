-- nvim/init.lua
require('config.options')
require('config.keymaps')
require('config.autocmds')

vim.o.background = "dark"
vim.cmd.colorscheme('catppuccin-frappe')

require("snacks").setup({ ... })
-- snacks keymaps ...

require('lze').register_handlers(require('lzextras').lsp)
require('lze').h.lsp.set_ft_fallback(function(name)
  return dofile(nixCats.pawsible({ "allPlugins", "opt", "nvim-lspconfig" }) .. "/lsp/" .. name .. ".lua").filetypes or {}
end)

require('lze').load({ ... })
