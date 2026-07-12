-- Allow multiple indent per selection
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Global
vim.keymap.set("n", "<leader><leader>q", "<cmd>qa<cr>", { desc = "Quit all" })
vim.keymap.set("n", "<leader><leader>s", "<cmd>w<cr>", { desc = "Save change" })

-- Buffer
vim.keymap.set("n", "<leader>b<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>b<S-Tab>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Terminal
vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], { desc = "Window command from terminal" })
