{ pkgs, configDir, ... }:
let
  hyprmoncfg = pkgs.callPackage "${configDir}/derivations/hyprmoncfg/hyprmoncfg.nix" { };
in
{
  home.packages = [ hyprmoncfg ];
  
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
