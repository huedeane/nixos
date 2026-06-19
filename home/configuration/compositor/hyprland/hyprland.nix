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
  home.packages = with pkgs; [
    grimblast
    satty
    wl-clipboard
  ];

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
      exec-once = [
        "uwsm app -- waybar"
        "uwsm app -- hyprmoncfgd"
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

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-termfilechooser
    ];
    config = {
      common.default = [ "gtk" ];
      common."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
      hyprland."org.freedesktop.impl.portal.FileChooser" = [ "termfilechooser" ];
    };
  };

  xdg.configFile."uwsm/env".text = ''
    export PATH="$HOME/.local/bin:$PATH"
    export GTK_USE_PORTAL=1
    export XCURSOR_THEME=catppuccin-frappe-green-cursors
    export XCURSOR_SIZE=36
    export EDITOR=nvim
    export VISUAL=nvim
    export MOZ_LEGACY_PROFILES=1
    export NIXOS_HOST=${hostname}
    export NIXOS_CONFIG=${config.xdg.configHome}/nixos
    export NIXOS_CONFIGHOMEDIR=${config.xdg.configHome}/nixos/home/configuration
    export SUDO_ASKPASS=$HOME/.local/bin/rofi-askpass
    exprot FZF_DEFAULT_OPTS_FILE=${config.xdg.configHome}/fzf/fzfrc
  '';

  xdg.configFile."uwsm/env-hyprland".text = ''
    export HYPRCURSOR_THEME=catppuccin-frappe-green-cursors
    export HYPRCURSOR_SIZE=36
  '';

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
