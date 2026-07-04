return {
  "fzf-lua",
  after = function()
    local fzf_lua = require("fzf-lua")
    local keymap = require("config.utils").keymap

    keymap({
      { "n", "<leader>fb", function() fzf_lua.buffers() end,   desc = "Buffer (fzf-lua)" },
      { "n", "<leader>ff", function() fzf_lua.live_grep() end, desc = "Find Files (fzf-lua)" },
      { "n", "<leader>fg", function() fzf_lua.buffers() end,   desc = "Live Grep (fzf-lua)" },
    })

    fzf_lua.setup({
      "telescope",
      fzf_colors = true,
      winopts = {
        border = "rounded",
      },
    })
  end,
}
