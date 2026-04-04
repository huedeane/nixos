{ config, pkgs, ... }:

{
  imports = [
  		../common/bash/bash.nix
  ];
  
  home.username = "huedeane";
  home.homeDirectory = "/home/huedeane";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    firefox
    kitty
    yazi
    rmpc
    tmux
    neovim
    vesktop
  ];

  programs.home-manager.enable = true;
}
