{ config, lib, username, ... }:

{
  programs.firefox = {
    enable = true;
      
    policies = lib.mkMerge [
      (import ./extensions.nix { inherit lib; })
      { }
    ];

    profiles = {
      ${username} = {
        isDefault = true;
        name = "${username}";
        settings = import ./settings.nix;
      };
    };
  };

  home.file.".mozilla/firefox/${username}/wallpaper/e3aa32e0-9a30-49ed-aa30-bd460a29149d".source = ./wallpaper/e3aa32e0-9a30-49ed-aa30-bd460a29149d;
  home.file.".mozilla/firefox/${username}/chrome".source = ./chrome;
}
