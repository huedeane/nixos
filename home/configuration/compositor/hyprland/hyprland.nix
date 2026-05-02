{ config, pkgs, inputs, username, hostname, configHomeDir, ... }: let
  hyprlandPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  smwPkgs = inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system};
in {

  imports = [ 
    ./plugins/hyprmoncfg/hyprmoncfg.nix 
    ./plugins/hyprpaper/hyprpaper.nix
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = false;
    package = hyprlandPkgs.hyprland;
    portalPackage = hyprlandPkgs.xdg-desktop-portal-hyprland;
    
    settings = {
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "EDITOR,nvim"
        "VISUAL,nvim"
        "PATH,$HOME/.local/bin:$PATH"
        "SUDO_ASKPASS,$HOME/.local/bin/rofi-askpass"
        "NIXOS_HOST,${hostname}"
        "NIXOS_CONFIG,${config.xdg.configHome}/nixos"
        "NIXOS_CONFIGHOMEDIR,${config.xdg.configHome}/nixos/home/configuration"
        "MOZ_LEGACY_PROFILES,1"
      ];
    };

    plugins = [
      smwPkgs.split-monitor-workspaces
    ];

    extraConfig = ''
      source = $HOME/.config/nixos/home/configuration/compositor/hyprland/hyprland.conf
    '';
  };

  home.file.".local/bin/nix-rebuild.sh" = {
    source = ./scripts/nix-rebuild.sh;
    executable = true;
  };
  
  home.file.".local/bin/nix-log.sh" = {
    source = ./scripts/nix-log.sh;
    executable = true;
  };
}
