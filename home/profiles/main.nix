{ config, pkgs, inputs, username, ... }:

{
  imports = [
  		../terminal/bash/bash.nix
      ../terminal/kitty/kitty.nix
      ../terminal/yazi/yazi.nix
      ../terminal/rmpc/rmpc.nix
      ../terminal/gitui/gitui.nix
      ../application/vesktop/vesktop.nix
      ../application/firefox/firefox.nix
  		../daemon/mpd/mpd.nix
      ../compositor/hyprland/hyprland.nix
      ../widget/rofi/rofi.nix
      #../widget/waybar/waybar.nix
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
      # Terminal
      tmux
      neovim
      cava
      
      # Application
      steam
      
      # Widget
      waybar

      # Notification
      dunst
      libnotify

      # Screenshot
      grimblast
      satty
      wl-clipboard
    ];
  };

  programs.home-manager.enable = true;
}
