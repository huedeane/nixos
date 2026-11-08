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
  startupBlankCursor =
    pkgs.runCommand "startup-blank-cursor"
      {
        nativeBuildInputs = [
          pkgs.imagemagick
          pkgs.xcursorgen
        ];
      }
      ''
        dir=$out/share/icons/startup-blank-cursor
        mkdir -p $dir/cursors
        magick -size 1x1 xc:none blank.png
        echo "1 0 0 blank.png" > blank.cfg
        xcursorgen blank.cfg $dir/cursors/left_ptr
        printf '[Icon Theme]\nName=startup-blank-cursor\n' > $dir/index.theme
      '';
in
{
  home.packages = with pkgs; [
    grimblast
    wl-clipboard
    socat
    # screen-gif.sh
    slurp
    wf-recorder
    ffmpeg
    brightnessctl
    startupBlankCursor
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
    extraLuaFiles."smw" = {
      autoLoad = true;
      content = ''
        smw = require("plugins.split-monitor-workspaces")
        smw.setup({
          workspace_count              = 5,
          keep_focused                 = true,
          enable_notifications         = false,
          enable_persistent_workspaces = true,
          enable_wrapping              = false,
          link_monitors                = false,
        })
      '';
    };
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

  # GNOME's ibus autostart entry warns under Hyprland; GNOME starts ibus itself anyway
  xdg.configFile."autostart/ibus-daemon.desktop".text = ''
    [Desktop Entry]
    Type=Application
    Name=IBus
    Hidden=true
  '';

  xdg.configFile."hypr/plugins/split-monitor-workspaces".source = inputs.split-monitor-workspaces;

  xdg.configFile."hypr/hyprland.lua".source = lib.mkIf editMode (
    lib.mkForce (config.lib.file.mkOutOfStoreSymlink "${dirPath}/hyprland.lua")
  );

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

  home.file.".local/bin/ags-reload.sh" = {
    source = ./scripts/ags-reload.sh;
    executable = true;
  };

  home.file.".local/bin/ags-restart.sh" = {
    source = ./scripts/ags-restart.sh;
    executable = true;
  };

  home.file.".local/bin/clip-notify.sh" = {
    source = ./scripts/clip-notify.sh;
    executable = true;
  };

  home.file.".local/bin/screen-gif.sh" = {
    source = ./scripts/screen-gif.sh;
    executable = true;
  };

  home.activation.ensureMonitorsLua = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    target="${config.xdg.configHome}/hypr/monitors.lua"
    if [ ! -e "$target" ]; then
      mkdir -p "$(dirname "$target")"
      touch "$target"
    fi
  '';
}
