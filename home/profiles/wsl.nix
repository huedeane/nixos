{
  config,
  pkgs,
  configHomeDir,
  hostname,
  username,
  ...
}:

{
  imports = [
    (configHomeDir + "/terminal/bash/bash.nix")
    (configHomeDir + "/terminal/yazi/yazi.nix")
    (configHomeDir + "/terminal/gitui/gitui.nix")
    (configHomeDir + "/terminal/fastfetch/fastfetch.nix")
    (configHomeDir + "/terminal/nixcats/nixcats.nix")
    (configHomeDir + "/terminal/tmux/tmux.nix")
    (configHomeDir + "/terminal/fzf/fzf.nix")
  ];

  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "24.11";

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIXOS_HOST = "${hostname}";
      NIXOS_CONFIG = "${config.xdg.configHome}/nixos";
      NIXOS_CONFIGHOMEDIR = "${config.xdg.configHome}/nixos/home/configuration";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];

    packages = with pkgs; [
      # Terminal
      caligula
    ];
  };

  programs.home-manager.enable = true;
}
