{ config, pkgs, lib, ... }:
let
  hyprmoncfg = pkgs.buildGoModule rec {
    pname = "hyprmoncfg";
    version = "1.4.1";
    src = pkgs.fetchFromGitHub {
      owner = "crmne";
      repo = "hyprmoncfg";
      rev = "main";
      hash = "sha256-UWt/gFrdxR7bTvX2ArMDDkXPkc6+VjjaopFq/5aGq+o="; 
    };
    vendorHash = "sha256-gQbjvdKtO0hCXrs9RnWo1s0YeHf5W9t+8AgS2ELXlPo="; 
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

  xdg.desktopEntries."hyprmoncfg" = {
    name = "Hyprmoncfg";
    genericName = "Monitor Management";
    exec = "kitty -e hyprmoncfg";
    icon = "kitty";
    categories = [ "Settings" "HardwareSettings" ];
  };
}
