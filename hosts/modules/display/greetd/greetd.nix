{
  config,
  hostname,
  inputs,
  lib,
  pkgs,
  username,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  astal = inputs.astal.packages.${system};
  # Same cursor as the session (home/configuration/appearance/pointer)
  cursor = config.home-manager.users.${username}.home.pointerCursor;
  # Remembers the last user and session between boots
  stateDir = "/var/lib/ags-greeter";

  # The AGS login screen (home/configuration/widget/ags/src/greeter.ts), bundled on its own
  # since it runs as the greeter user, before any home-manager config exists
  greeter = pkgs.stdenv.mkDerivation {
    pname = "ags-greeter";
    version = "1.0.0";
    src = ../../../../home/configuration/widget/ags/src;

    nativeBuildInputs = [
      inputs.ags.packages.${system}.default
      pkgs.wrapGAppsHook4
      pkgs.gobject-introspection
    ];
    buildInputs = [
      pkgs.glib
      pkgs.gjs
      astal.astal4
      astal.io
      astal.greet
    ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      ags bundle greeter.ts $out/bin/ags-greeter \
        -d "GREETER_WALLPAPER='${../../../../resources/wallpaper.png}'" \
        -d "GREETER_SESSIONS='${config.services.displayManager.sessionData.desktops}/share/wayland-sessions'" \
        -d "GREETER_STATE='${stateDir}'" \
        -d "GREETER_SWAYMSG='${pkgs.sway}/bin/swaymsg'"
      runHook postInstall
    '';
  };

  # Sway instead of cage, which can only show the greeter on the last connected monitor (the
  # desktop's DP-2, turned off here so the greeter lands on the main one)
  swayConfig = pkgs.writeText "greeter-sway.conf" ''
    ${lib.optionalString (hostname == "desktop") "output DP-2 disable"}
    default_border none
    seat seat0 xcursor_theme ${cursor.name} 36
    exec "${greeter}/bin/ags-greeter; ${pkgs.sway}/bin/swaymsg exit"
  '';
in
{
  environment.systemPackages = [
    cursor.package
    # `cage -- ags-greeter` tries the login screen in a window, in demo mode (fzf cheatsheet)
    greeter
    pkgs.cage
  ];

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "greeter";
      # systemd-cat: sway's log goes to the journal, not the tty it reappears on at login
      command = toString [
        "${pkgs.systemd}/bin/systemd-cat -t ags-greeter"
        "env"
        "XCURSOR_THEME=${cursor.name}"
        "XCURSOR_SIZE=36"
        "XCURSOR_PATH=/run/current-system/sw/share/icons"
        "${pkgs.sway}/bin/sway --config ${swayConfig}"
      ];
    };
  };

  # Hides the tty text cursor, which blinked top left between the greeter exiting and Hyprland drawing
  # (only with greetd on, so the TTY Login GRUB entry keeps its cursor)
  boot.kernelParams = lib.mkIf config.services.greetd.enable [ "vt.global_cursor_default=0" ];

  systemd.tmpfiles.rules = [ "d ${stateDir} 0755 greeter greeter -" ];
}
