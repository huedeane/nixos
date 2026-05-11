{ pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
    name = "catppuccin-frappe-green-cursors";
    size = 36;
    package = pkgs.catppuccin-cursors.frappeGreen;
  };
}
