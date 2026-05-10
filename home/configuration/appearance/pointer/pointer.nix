{ pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
    name = "catppuccin-cursors";
    size = 24;
    package = pkgs.catppuccin-cursors.frappeGreen;
  };
}
