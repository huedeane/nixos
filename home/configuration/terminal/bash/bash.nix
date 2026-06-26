{
  config,
  lib,
  hostname,
  ...
}:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/bash";
in
{
  programs.bash = {
    enable = true;

    shellAliases = {
      m = "rmpc";
      g = "gitui";
      bash-update = "source ~/.bashrc";
      secret-edit = "nvim ${config.xdg.configHome}/sops/age/keys.txt";
      hypr-update = "nvim ${config.xdg.configHome}/nixos/home/configuration/compositor/hyprland/hyprland.lua";
    };

    profileExtra = lib.mkIf (hostname == "wsl1") ''
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';

    initExtra = ''
      # Functions
      source ${dirPath}/function/functions.sh

      # PS1
      source ${dirPath}/function/ps1.sh

      # Secrets
      source ${dirPath}/function/secrets.sh
    '';
  };
}
