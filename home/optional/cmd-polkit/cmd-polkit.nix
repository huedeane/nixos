{ config, pkgs, ... }:

let
  cmd-polkit = pkgs.callPackage "../../../pkgs/cmd-polkit.nix" {};
in
{
  home.packages = [ cmd-polkit ];

  systemd.user.services.cmd-polkit = {
    Unit = {
      Description = "cmd-polkit authentication agent";
      After = [ "graphical-session.target" ];
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${cmd-polkit}/bin/cmd-polkit-agent";
      Restart = "on-failure";
    };
  };
}
