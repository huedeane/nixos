{ config, lib, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/gitui";
  setting = {
    enable = true;
  };
in
{
  programs.gitui = setting // (if !editMode then { 
    keyConfig = builtins.readFile ./key_bindings.ron;
    theme = builtins.readFile ./theme.ron;
  } else {});

 xdg.configFile = if editMode then {
    "gitui/key_bindings.ron".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "${dirPath}/key_bindings.ron");
    "gitui/theme.ron".source = lib.mkForce (config.lib.file.mkOutOfStoreSymlink "${dirPath}/theme.ron");
  } else {};

  xdg.desktopEntries."gitui" = {
    name = "GitUI";
    genericName = "Version Control";
    exec = "kitty --class tui-gitui -e gitui -d ${config.home.homeDirectory}/.config/nixos";
    icon = "kitty";
    type = "Application";
    terminal = false;
    categories = [ "X-TUI" ];
    settings = {
      Keywords = "Git;Tui;Kitty;";
    };
  };
}
