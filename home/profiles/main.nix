{ config, pkgs, configHomeDir, hostname, username, inputs, ... }:

{
  imports = [
      inputs.sops-nix.homeManagerModules.sops
      (configHomeDir + "/terminal/bash/bash.nix")
      (configHomeDir + "/terminal/kitty/kitty.nix")
      (configHomeDir + "/terminal/yazi/yazi.nix")
      (configHomeDir + "/terminal/rmpc/rmpc.nix")
      (configHomeDir + "/terminal/git/git.nix")
      (configHomeDir + "/terminal/gitui/gitui.nix")
      (configHomeDir + "/compositor/hyprland/hyprland.nix")
      (configHomeDir + "/daemon/mpd/mpd.nix")
      (configHomeDir + "/daemon/dunst/dunst.nix")
      (configHomeDir + "/daemon/udiskie/udiskie.nix")
      (configHomeDir + "/application/vesktop/vesktop.nix")
      (configHomeDir + "/application/firefox/firefox.nix")
      (configHomeDir + "/application/obsidian/obsidian.nix")
      (configHomeDir + "/widget/rofi/rofi.nix")
      # (configHomeDir + "/security/sops/sops.nix")
      #(configHomeDir + "/widget/waybar/waybar.nix")
  ];

  home = {
    username = "${username}";
  	homeDirectory = "/home/${username}";
  	stateVersion = "24.11";
    
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_HOST = "${hostname}";
      NIXOS_CONFIG = "${config.xdg.configHome}/nixos";
      NIXOS_CONFIGHOMEDIR = "${config.xdg.configHome}/nixos/home/configuration";
      MOZ_LEGACY_PROFILES = "1";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      # Terminal
      tmux
      neovim
      cava  
      caligula

      # Application
      steam
      
      # Widget
      waybar

      # Library
      libnotify

      # Screenshot
      grimblast
      satty
      wl-clipboard
    ];
  };

  sops = {
    defaultSopsFile = "/home/${username}/.config/nixos/secrets/secrets2.yaml";
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/${username}/.config/sops/age/keys.txt";

    secrets = {
      "github/username" = {};
      "github/email" = {};
      "github/key" = {};
      "chatgpt/key" = {};
    };
  };

  programs.home-manager.enable = true;
}
