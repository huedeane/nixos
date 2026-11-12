{ pkgs, ... }:
let
  kdeconnectNotify = pkgs.writeShellApplication {
    name = "kdeconnect-notify";
    runtimeInputs = with pkgs; [
      dbus
      systemd
      libnotify
      xdg-utils
      gnused
      coreutils
    ];
    text = builtins.readFile ./kdeconnect-notify.sh;
  };
in
{
  services.kdeconnect = {
    enable = true;
    indicator = true;
  };

  # kdeconnectd has no job tracker here, so received files arrive silently; notify on each one
  systemd.user.services.kdeconnect-notify = {
    Unit = {
      Description = "Notify on files received via KDE Connect";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${kdeconnectNotify}/bin/kdeconnect-notify";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
