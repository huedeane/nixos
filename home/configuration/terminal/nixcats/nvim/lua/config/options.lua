vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10
vim.wo.number = true
vim.o.mouse = 'a'
vim.opt.cpoptions:append('I')
vim.o.expandtab = true
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.wo.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.completeopt = 'menu,preview,noselect'
vim.o.termguicolors = true
vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0
