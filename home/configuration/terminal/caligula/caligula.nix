{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    caligula 
  ];
  
  xdg.desktopEntries."caligula" = {
    name = "Caligula";
    genericName = "ISO Burner";
    exec = "kitty --class tui-caligula -e caligula burn";
    icon = "kitty";
    categories = [ "Utility" "X-TUI"];
  };
}
