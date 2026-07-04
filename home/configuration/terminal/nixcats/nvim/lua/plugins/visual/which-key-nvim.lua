return {
  "which-key.nvim",
  event = "DeferredUIEnter",
  after = function()
    local which_key = require("which-key")

    which_key.add({
      { "<leader>f", group = " (Plugin) fzf-lua" },
      { "<leader>e", group = " (Plugin) edgy" },
      { "<leader>w", group = " window" },
      { "<leader>b", group = " buffer" },
    })

    vim.keymap.set("n", "<leader>w", function()
      which_key.show({ keys = "<c-w>", loop = true })
    end, { desc = "Window mode (loop)" })

    vim.keymap.set("n", "<leader>bb", function()
      which_key.show({ keys = "<leader>b", loop = true })
    end, { desc = "Buffer hydra" })
  end,
}
