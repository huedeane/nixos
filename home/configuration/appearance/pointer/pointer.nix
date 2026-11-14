{ pkgs, ... }:

{
  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    hyprcursor.enable = true;
    name = "catppuccin-frappe-lavender-cursors";
    size = 24;
    package = pkgs.catppuccin-cursors.frappeLavender;
  };
}
