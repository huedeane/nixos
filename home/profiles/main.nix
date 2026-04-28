{ config, pkgs, configHomeDir, username, ... }:

{
  imports = [
  		(configHomeDir + "/terminal/bash/bash.nix")
      (configHomeDir + "/terminal/kitty/kitty.nix")
      (configHomeDir + "/terminal/yazi/yazi.nix")
      (configHomeDir + "/terminal/rmpc/rmpc.nix")
      (configHomeDir + "/terminal/gitui/gitui.nix")
      (configHomeDir + "/compositor/hyprland/hyprland.nix")
      (configHomeDir + "/daemon/mpd/mpd.nix")
      (configHomeDir + "/application/vesktop/vesktop.nix")
      (configHomeDir + "/application/firefox/firefox.nix")
      (configHomeDir + "/widget/rofi/rofi.nix")
      #(configHomeDir + "/widget/waybar/waybar.nix")
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

      # Daemon
      dunst

      # Library
      libnotify

      # Screenshot
      grimblast
      satty
      wl-clipboard
    ];
  };

  programs.home-manager.enable = true;
}
