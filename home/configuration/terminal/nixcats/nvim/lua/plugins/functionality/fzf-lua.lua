return {
  "fzf-lua",
  after = function()
    require("fzf-lua").setup({
      "telescope",
      fzf_colors = true,
      winopts = {
        border = "rounded",
      },
    })
  end,
}
