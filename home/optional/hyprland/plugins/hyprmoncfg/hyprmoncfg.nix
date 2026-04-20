{ config, pkgs, ... }:
let
  hyprmoncfg = pkgs.buildGoModule rec {
    pname = "hyprmoncfg";
    version = "1.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "crmne";
      repo = "hyprmoncfg";
      rev = "v${version}";
      hash = "sha256-hflSsenv3rXKHVXm0PkB0Bag+dY7zLc8CuKzr4nqUuk=";
    };
    vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    subPackages = [
      "cmd/hyprmoncfg"
      "cmd/hyprmoncfgd"
    ];
  };
in
{
  home.packages = [ hyprmoncfg ];

  systemd.user.services.hyprmoncfgd = {
    Unit = {
      Description = "Hyprland monitor configuration daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${hyprmoncfg}/bin/hyprmoncfgd";
      Restart = "on-failure";
      RestartSec = "3s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
