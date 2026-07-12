return {
  "fzf-lua",
  after = function()
    local fzf_lua = require("fzf-lua")
    local keymap = require("config.utils").keymap

    keymap({
      { "n", "<leader>fb", function() fzf_lua.buffers() end,   desc = "Buffer (fzf-lua)" },
      { "n", "<leader>ff", function() fzf_lua.files() end,     desc = "File (fzf-lua)" },
      { "n", "<leader>fF", function() fzf_lua.live_grep() end, desc = "Grep File (fzf-lua)" },
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
