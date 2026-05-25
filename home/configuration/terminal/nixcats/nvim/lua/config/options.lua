vim.g.mapleader = ' '        -- set space as the global leader key
vim.g.maplocalleader = ' '   -- set space as the local leader key (for buffer-local mappings)

-------------
-- Spacing --
-------------
vim.opt.expandtab = true       -- insert spaces instead of tabs
vim.opt.tabstop = 2            -- number of spaces a tab character counts for
vim.opt.shiftwidth = 2         -- number of spaces for each indent level
vim.opt.shiftround = true      -- round indentation to nearest multiple of shiftwidth
vim.opt.smartindent = true     -- automatically insert indents for new lines
vim.opt.breakindent = true     -- wrapped lines continue visually indented
-- vim.opt.cpoptions:append('I')  -- dont move cursor to start of line on certain movements

-----------
-- Cases --
-----------
vim.o.ignorecase = true        -- case-insensitive search by default
vim.o.smartcase = true         -- override ignorecase if search contains uppercase

------------
-- Visual --
------------
vim.opt.list = true 	                                      -- show invisible characters
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- define how invisible chars look
vim.opt.number = true                                       -- show absolute line numbers
vim.opt.relativenumber = false                              -- show relative line numbers (combined with above: hybrid mode)
vim.opt.signcolumn = "yes"                                  -- always show the sign column
vim.opt.termguicolors = true                                -- enable 24-bit RGB color in the terminal
vim.opt.scrolloff = 10                                      -- keep 10 lines visible above/below cursor when scrolling
vim.opt.conceallevel = 0                                    -- don't hide * markup for bold and italic but not substitution markers
vim.opt.cursorline = true                                   -- highlight the line the cursor is on
vim.opt.smoothscroll = true        -- scroll by screen lines rather than file lines

------------
-- Search --
------------
vim.opt.hlsearch = true           -- highlight all search matches
vim.opt.inccommand = 'split'      -- show live preview of substitutions in a split
-- vim.opt.inccommand = "nosplit" -- same as yours but preview stays inline instead of a split


-------------------
-- Functionality --
-------------------
vim.opt.mouse = 'a'                                                 -- enable mouse support in all modes
vim.opt.undofile = true                                             -- persist undo history across sessions
vim.opt.completeopt = 'menu,preview,noselect'                       -- completion menu: show menu, preview, dont auto-select
-- vim.opt.completeopt = "menu,menuone,noselect"                    -- similar to yours but uses menuone instead of preview
vim.opt.updatetime = 250                                            -- ms before writing swap file / triggering CursorHold
vim.opt.timeoutlen = 300                                            -- ms to wait for a mapped sequence to complete
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"  -- sync with system clipboard, disabled over SSH to use OSC 52
vim.opt.confirm = true                                              -- prompt to save changes before exiting a modified buffer



-- vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')          -- clear search highlights on Esc
-- -- =====================
-- -- Only in LazyVim
-- -- =====================
-- opt.autowrite = true           -- automatically save before commands like :next and :make
-- opt.fillchars = {              -- characters used to fill UI elements
--   foldopen = "",
--   foldclose = "",
--   fold = " ",
--   foldsep = " ",
--   diff = "╱",
--   eob = " ",
-- }
-- opt.foldlevel = 99             -- start with all folds open
-- opt.foldmethod = "indent"      -- fold based on indentation
-- opt.foldtext = ""              -- use default text for closed folds
-- opt.formatoptions = "jcroqlnt" -- control auto-formatting: join comments, wrap, insert comment leader etc
-- opt.grepformat = "%f:%l:%c:%m" -- format string for grep output
-- opt.grepprg = "rg --vimgrep"   -- use ripgrep as the grep program
-- opt.jumpoptions = "view"       -- restore view when jumping through the jumplist
-- opt.laststatus = 3             -- single global statusline instead of one per window
-- opt.linebreak = true           -- wrap long lines at word boundaries
-- opt.pumblend = 10              -- pseudo-transparency for the popup menu
-- opt.pumheight = 10             -- max number of items in the popup menu
-- opt.ruler = false              -- hide the default cursor position ruler
-- opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" } -- what to save in a session
-- opt.shortmess:append({ W = true, I = true, c = true, C = true }) -- suppress various intro and completion messages
-- opt.showmode = false           -- dont show -- INSERT --, statusline handles it
-- opt.sidescrolloff = 8          -- keep 8 columns visible to the left/right of cursor
-- opt.spelllang = { "en" }       -- set spell check language to english
-- opt.splitbelow = true          -- open horizontal splits below the current window
-- opt.splitkeep = "screen"       -- keep text on screen when splitting
-- opt.splitright = true          -- open vertical splits to the right of the current window
-- opt.undolevels = 10000         -- maximum number of undo steps
-- opt.virtualedit = "block"      -- allow cursor to move into empty space in visual block mode
-- opt.wildmode = "longest:full,full" -- command-line completion: complete longest match then full list
-- opt.winminwidth = 5            -- minimum width of any window
-- vim.g.markdown_recommended_style = 0 -- disable markdown's opinionated indentation defaults
