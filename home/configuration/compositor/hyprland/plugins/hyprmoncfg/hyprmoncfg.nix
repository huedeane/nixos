{ pkgs, configDir, ... }:
let
  hyprmoncfg = pkgs.callPackage "${configDir}/derivations/hyprmoncfg.nix" { };
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
    exec = "kitty --class tui-hyprmoncfg -e hyprmoncfg";
    icon = "kitty";
    terminal = false;
    type = "Application";
    categories = [ "Settings" "HardwareSettings" "X-TUI" ];
    settings = {
      Keywords = "Settings;HardwareSettings;Tui";
    };
  };
}
