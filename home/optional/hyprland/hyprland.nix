{ config, pkgs, inputs, hostname, ... }: let
  hyprlandPkgs = inputs.hyprland.packages.${pkgs.system};
in {
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
      inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
    ];

    extraConfig = builtins.readFile ./hyprland.conf;
  };

  services.hyprpaper = {
    enable = true;
  };
  
  home.file.".config/hypr/hyprpaper.conf".source = ./plugins/hyprpaper/hyprpaper.conf;
  home.file.".local/bin/nix-rebuild" = {
    source = ./scripts/nix-rebuild;
    executable = true;
  };
}
