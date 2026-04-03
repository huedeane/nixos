{ config, pkgs, ... }:

{
  imports = [
  		./common/bash/bash.nix
  		./common/neovim/neovim.nix
  ];
  
  home.username = "huedeane";
  home.homeDirectory = "/home/huedeane";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    # Apps
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
