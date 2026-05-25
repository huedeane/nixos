{ config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/git";
  setting = {
    enable = true;
    ignores = [
      ".direnv"
      "*.swp"
      "*~"
      ".DS_Store"
    ];
    signing.format = null;
  };
in
{
  programs.git = setting // (if !editMode then { 
    extraConfig = builtins.readFile ./config;
  } else {});

 xdg.configFile = if editMode then {
    "git/config".source = config.lib.file.mkOutOfStoreSymlink "${dirPath}/config";
  } else {};
}


