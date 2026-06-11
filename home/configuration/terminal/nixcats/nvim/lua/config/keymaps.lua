-- Allow multiple indent per selection
vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

-- Toggle edgy sidebar without selecting it
vim.keymap.set("n", "<C-e>", function()
  require("edgy").toggle("left")
  vim.defer_fn(require("edgy").goto_main, 10)
end, { desc = "Toggle left panel" })
