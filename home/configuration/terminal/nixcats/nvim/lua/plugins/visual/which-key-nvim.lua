return {
  "which-key.nvim",
  event = "DeferredUIEnter",
  after = function()
    local which_key = require("which-key")

    which_key.add({
      { "<leader>f",       group = " (Plugin) fzf-lua" },
      { "<leader>e",       group = " (Plugin) edgy" },
      { "<leader>b",       group = " buffer" },
      { "<leader><space>", group = " global" },
      { "<leader>l",       group = " (Plugin) lsp" },
    })

    vim.keymap.set("n", "<leader>bb", function()
      which_key.show({ keys = "<leader>b", loop = true })
    end, { desc = "Buffer hydra" })
  end,
}
