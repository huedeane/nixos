{ config, lib, ... }:

{
  programs.firefox = {
    enable = true;
      
    policies = lib.mkMerge [
      (import ./extensions.nix { inherit lib; })
      { }
    ];

    profiles = {
      huedeane = {
        isDefault = true;
        name = "huedeane";
        settings = import ./settings.nix;
      };
    };
  };

  home.file.".mozilla/firefox/huedeane/wallpaper/e3aa32e0-9a30-49ed-aa30-bd460a29149d".source = ./wallpaper/e3aa32e0-9a30-49ed-aa30-bd460a29149d;
  home.file.".mozilla/firefox/huedeane/chrome".source = ./chrome;
}
