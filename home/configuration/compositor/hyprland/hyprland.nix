{
  config,
  pkgs,
  inputs,
  hostname,
  editMode,
  lib,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/compositor/hyprland";
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
    configType = "lua";
    xwayland.enable = true;
    systemd.enable = false;
    package = hyprlandPkgs.hyprland;
    portalPackage = hyprlandPkgs.xdg-desktop-portal-hyprland;
    extraConfig = if editMode then "" else builtins.readFile ./hyprland.lua;
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
    export FZF_DEFAULT_OPTS_FILE=${config.xdg.configHome}/fzf/fzfrc
  '';

  xdg.configFile."uwsm/env-hyprland".text = ''
    export HYPRCURSOR_THEME=catppuccin-frappe-green-cursors
    export HYPRCURSOR_SIZE=36
  '';

  xdg.configFile."hypr/plugins.lua".text = ''
    hl.on("hyprland.start", function()
      hl.exec_cmd("${hyprlandPkgs.hyprland}/bin/hyprctl plugin load ${smwPkgs.split-monitor-workspaces}/lib/libsplit-monitor-workspaces.so")
    end)
  '';

  xdg.configFile."hypr/hyprland.lua".source =
    lib.mkIf editMode (lib.mkForce (
      config.lib.file.mkOutOfStoreSymlink "${dirPath}/hyprland.lua"
    ));

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

  home.activation.ensureMonitorsLua =
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      target="${config.xdg.configHome}/hypr/monitors.lua"
      if [ ! -e "$target" ]; then
        mkdir -p "$(dirname "$target")"
        touch "$target"
      fi
    '';
  }
