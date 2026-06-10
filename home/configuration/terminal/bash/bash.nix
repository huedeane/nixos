{
  config,
  lib,
  hostname,
  ...
}:

{
  programs.bash = {
    enable = true;

    shellAliases = {
      m = "rmpc";
      g = "gitui";
      bash-update = "source ~/.bashrc";
      secret-edit = "nvim ${config.xdg.configHome}/sops/age/keys.txt";
      hypr-update = "nvim ${config.xdg.configHome}/nixos/home/configuration/compositor/hyprland/hyprland.conf";
    };

    profileExtra = lib.mkIf (hostname == "wsl1") ''
      if [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      fi
    '';

    initExtra = ''
      # Functions
      source ${./function/functions.sh}

      # PS1
      source ${./function/ps1.sh}

      # Secrets
      source ${./function/secrets.sh}
    '';
  };
}
