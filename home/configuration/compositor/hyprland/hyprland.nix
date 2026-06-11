{
  config,
  pkgs,
  inputs,
  hostname,
  editMode,
  ...
}:
let
  hyprlandPkgs = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system};
  smwPkgs = inputs.split-monitor-workspaces.packages.${pkgs.stdenv.hostPlatform.system};
in
{

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
        "HYPRCURSOR_THEME,catppuccin-frappe-green-cursors"
        "HYPRCURSOR_SIZE,36"
        "XCURSOR_THEME,catppuccin-frappe-green-cursors"
        "XCURSOR_SIZE,36"
        "EDITOR,nvim"
        "VISUAL,nvim"
        "PATH,$HOME/.local/bin:$PATH"
        "SUDO_ASKPASS,$HOME/.local/bin/rofi-askpass"
        "NIXOS_HOST,${hostname}"
        "NIXOS_CONFIG,${config.xdg.configHome}/nixos"
        "NIXOS_CONFIGHOMEDIR,${config.xdg.configHome}/nixos/home/configuration"
        "MOZ_LEGACY_PROFILES,1"
      ];

      exec-once = [
        "uwsm app -- waybar"
        "uwsm qpp -- hyprmoncfgd"
        "uwsm app -- rofi-polkit-agent"
        "uwsm app -- dunst-clipboard-notify.sh"
      ];
    };

    plugins = [
      smwPkgs.split-monitor-workspaces
    ];

    extraConfig =
      if !editMode then
        builtins.readFile ./hyprland.conf
      else
        "source = $HOME/.config/nixos/home/configuration/compositor/hyprland/hyprland.conf";
  };

  home.file.".local/bin/nix-rebuild.sh" = {
    source = ./scripts/nix-rebuild.sh;
    executable = true;
  };

  home.file.".local/bin/nix-rebuild-edit.sh" = {
    source = ./scripts/nix-rebuild-edit.sh;
    executable = true;
  };

  home.file.".local/bin/nix-log.sh" = {
    source = ./scripts/nix-log.sh;
    executable = true;
  };

  home.file.".local/bin/dunst-clipboard-notify.sh" = {
    source = ./scripts/dunst-clipboard-notify.sh;
    executable = true;
  };
}
