{ config, ... }:

{
  programs.rofi = {
    enable = true;
  };

  xdg.configFile = {
    "rofi/config.rasi".source = ./config.rasi;
    "rofi/catppuccin-frappe.rasi".source = ./catppuccin-frappe.rasi;
  };
}
