{ config, pkgs, inputs, username, ... }:

{
  imports = [
  		../common/bash/bash.nix
  		../common/mpd/mpd.nix
      ../common/kitty/kitty.nix
      ../common/yazi/yazi.nix
      ../common/rmpc/rmpc.nix
      ../common/gitui/gitui.nix
      ../optional/vesktop/vesktop.nix
      ../optional/firefox/firefox.nix
      ../optional/hyprland/hyprland.nix
      ../optional/rofi/rofi.nix
      #../optional/waybar/waybar.nix
  ];
  
  home = {
    username = "${username}";
  	homeDirectory = "/home/${username}";
  	stateVersion = "24.11";
    
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_HOST = "main";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      tmux
      neovim
      cava
      rofi
      steam
      waybar
      dunst
      libnotify
      grimblast
      satty
      wl-clipboard
    ];
  };

  programs.home-manager.enable = true;
}
