{ config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/kitty";
  setting = {
    enable = true;
  };
in
{
  programs.kitty = setting // (if !editMode then {
    extraConfig = builtins.readFile ./kitty.conf;
  } else {});

 xdg.configFile = if editMode then {
    "kitty/kitty.conf".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/kitty.conf";
    "kitty/themes/catppuccin-frappe-theme.conf".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/themes/catppuccin-frappe-theme.conf";
  } else {
    "kitty/themes/catppuccin-frappe-theme.conf".source = ./themes/catppuccin-frappe-theme.conf;
  };
}
