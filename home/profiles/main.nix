{ config, pkgs, inputs, ... }:

{
  imports = [
  		../common/bash/bash.nix
  		../common/mpd/mpd.nix
      ../common/kitty/kitty.nix
      ../common/yazi/yazi.nix
      ../common/rmpc/rmpc.nix
      ../optional/vesktop/vesktop.nix
      ../optional/firefox/firefox.nix
      #../optional/hyprland/hyprland.nix
      ../optional/rofi/rofi.nix
  ];
  
  home = {
    username = "huedeane";
  	homeDirectory = "/home/huedeane";
  	stateVersion = "24.11";
  		
  	sessionVariables = {
    	EDITOR = "nvim";
    	VISUAL = "nvim";
    };

    packages = with pkgs; [
      tmux
      neovim
      cava
      rofi
      steam
      hyprland
    ];
  };

  programs.home-manager.enable = true;
}
