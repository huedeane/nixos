{ config, pkgs, inputs, hostname, ... }: let
  hyprlandPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  smwPkgs = inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system};
in {

  imports = [ 
    ./plugins/hyprmoncfg/hyprmoncfg.nix 
    ./plugins/hyprpaper/hyprpaper.nix
  ];
  
  wayland.windowManager.hyprland = {
    enable = true;
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
        "NIXOS_CONFIG,/home/huedeane/.config/nixos"
        "NIXOS_HOST,${hostname}"
      ];
    };

    plugins = [
      smwPkgs.split-monitor-workspaces
    ];

    # extraConfig = builtins.readFile ./hyprland.conf;
    extraConfig = ''
      source = ${config.home.homeDirectory}/.config/nixos/home/optional/hyprland/hyprland.conf
    '';
  };

  home.file.".local/bin/nix-rebuild" = {
    source = ./scripts/nix-rebuild;
    executable = true;
  };
}
