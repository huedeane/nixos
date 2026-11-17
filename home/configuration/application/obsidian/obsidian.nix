{
  lib,
  config,
  ...
}:

let
  repoDir = "${config.home.homeDirectory}/.config/nixos/home/configuration/application/obsidian";
in
{
  programs.obsidian.enable = true;

  home.file.".local/bin/obsidian-open.sh" = {
    source = ./obsidian-open.sh;
    executable = true;
  };

  # Opens .md files from file managers through obsidian-open.sh (hidden from launchers)
  xdg.desktopEntries."obsidian-open" = {
    name = "Obsidian (open file)";
    exec = "${config.home.homeDirectory}/.local/bin/obsidian-open.sh %f";
    icon = "obsidian";
    terminal = false;
    noDisplay = true;
    mimeType = [ "text/markdown" ];
  };

  # Settings Profiles reads profiles from here; link each one in profile/ to this repo, so saving
  # a profile writes straight to it
  xdg.dataFile = lib.mapAttrs' (
    name: _:
    lib.nameValuePair "obsidianplugins/Profiles/${name}" {
      source = config.lib.file.mkOutOfStoreSymlink "${repoDir}/profile/${name}";
      force = true;
    }
  ) (lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./profile));
}
