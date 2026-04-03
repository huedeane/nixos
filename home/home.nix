{ config, pkgs, ... }:

{
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
  ];

  programs.home-manager.enable = true;
}
