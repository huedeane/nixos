{ config, ... }:

{
  programs.rofi = {
    enable = true;
    terminal = "kitty";
    location = "center";
    theme = ./catppuccin-frappe.rasi;

    extraConfig = {
      modi = "drun,run,window";
      show-icons = true;
    };
  };
}
