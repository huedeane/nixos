{ config, pkgs, ... }:

{
  imports = [
  		../common/bash/bash.nix
  		../common/mpd/mpd.nix
      ../common/kitty/kitty.nix
      ../common/yazi/yazi.nix
  ];
  
  home.username = "huedeane";
  home.homeDirectory = "/home/huedeane";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    mpd
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
