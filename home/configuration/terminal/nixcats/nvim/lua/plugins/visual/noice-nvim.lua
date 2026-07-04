return {
  "noice.nvim",
  event = "DeferredUIEnter",
  before = function(_)
    vim.cmd.packadd("nui.nvim")
  end,
  after = function(_)
    require("noice").setup({
      cmdline = {
        view = "cmdline_popup",
      },
      messages = {
        enabled = true,
        view = "notify",
        view_error = "notify",
        view_warn = "notify",
      },
      routes = {
        {
          filter = { event = "msg_show", kind = "" },
          view = "mini",
        },
      },
    })
  end,
}
