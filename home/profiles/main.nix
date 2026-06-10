{
  config,
  pkgs,
  configHomeDir,
  hostname,
  username,
  ...
}:

{
  imports = [
    (configHomeDir + "/terminal/bash/bash.nix")
    (configHomeDir + "/terminal/kitty/kitty.nix")
    (configHomeDir + "/terminal/yazi/yazi.nix")
    (configHomeDir + "/terminal/rmpc/rmpc.nix")
    (configHomeDir + "/terminal/git/git.nix")
    (configHomeDir + "/terminal/gitui/gitui.nix")
    (configHomeDir + "/terminal/fastfetch/fastfetch.nix")
    (configHomeDir + "/terminal/nixcats/nixcats.nix")
    (configHomeDir + "/compositor/hyprland/hyprland.nix")
    (configHomeDir + "/daemon/mpd/mpd.nix")
    (configHomeDir + "/daemon/dunst/dunst.nix")
    (configHomeDir + "/daemon/udiskie/udiskie.nix")
    (configHomeDir + "/daemon/clipvault/clipvault.nix")
    (configHomeDir + "/application/vesktop/vesktop.nix")
    (configHomeDir + "/application/firefox/firefox.nix")
    (configHomeDir + "/application/obsidian/obsidian.nix")
    (configHomeDir + "/application/godot/godot.nix")
    (configHomeDir + "/widget/rofi/rofi.nix")
    # (configHomeDir + "/widget/ags/ags.nix")
    (configHomeDir + "/security/sops/sops.nix")
    #(configHomeDir + "/widget/waybar/waybar.nix")
    (configHomeDir + "/appearance/pointer/pointer.nix")
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
      cava
      caligula
      tree

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

      # Formatter
      nixfmt-rfc-style

      # Find
      fzf
      fd
      ripgrep
    ];
  };

  programs.home-manager.enable = true;
}
