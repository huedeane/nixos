local style     = {}
local colors    = require("catppuccin.palettes").get_palette("frappe")

-- Base
local rosewater = colors.rosewater
local flamingo  = colors.flamingo
local pink      = colors.pink
local mauve     = colors.mauve
local red       = colors.red
local maroon    = colors.maroon
local peach     = colors.peach
local yellow    = colors.yellow
local green     = colors.green
local teal      = colors.teal
local sky       = colors.sky
local sapphire  = colors.sapphire
local blue      = colors.blue
local lavender  = colors.lavender
local text      = colors.text
local subtext1  = colors.subtext1
local subtext0  = colors.subtext0
local overlay2  = colors.overlay2
local overlay1  = colors.overlay1
local overlay0  = colors.overlay0
local surface2  = colors.surface2
local surface1  = colors.surface1
local surface0  = colors.surface0
local base      = colors.base
local mantle    = colors.mantle
local crust     = colors.crust


style.setup = function()
  -- neo-tree
  vim.api.nvim_set_hl(0, "NeoTreeWinSeparator", { fg = lavender })
  vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = mantle })
  vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = base })
end

return style
