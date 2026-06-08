{ pkgs, ... }:

# nix-prefetch-url --name godot-mono.zip 'https://downloads.godotengine.org/?version=4.6&flavor=dev3&slug=mono_linux_x86_64.zip&platform=linux.64'

{
  programs.godot = {
    enable  = true;

    settings = {
      version = "4.6.3";
      flavor  = "stable";
      type = "mono";
      sha256 = "17hap8g6prnx0xqmss5cfz1z1v468n3dyfip8vyh60h6hmkqlakh";
    };
  };

  xdg.desktopEntries."godot" = {
    name = "Godot";
    genericName = "Game Engine";
    exec = "godot-mono";
    icon = "${pkgs.godot_4}/share/icons/hicolor/scalable/apps/godot.svg";
    type = "Application";
    terminal = false;
    categories = [ "Development" "IDE" ];
    settings = {
      Keywords = "game;engine;2d;3d;gdscript;csharp;";
    };
  };
}
