{ pkgs, lib, config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/tmux";
  tmux-autoreload = pkgs.tmuxPlugins.mkTmuxPlugin {
    pluginName = "tmux-autoreload";
    rtpFilePath = "tmux-autoreload.tmux";
    version = "v0.0.1";
    src = pkgs.fetchFromGitHub {
      owner = "b0o";
      repo = "tmux-autoreload";
      rev = "main";
      sha256 = "sha256-9Rk+VJuDqgsjc+gwlhvX6uxUqpxVD1XJdQcsc5s4pU4=";
    };
  };
in
{
  home.packages = [ pkgs.entr ];

  programs.tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'frappe'
        '';
      }
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      battery
      prefix-highlight
      tmux-fzf
    ]
    ++ lib.optional editMode {
      plugin = tmux-autoreload;
      extraConfig = "set -g @tmux-autoreload-configs '${dirPath}/tmux.conf'";
    };

    extraConfig =
      if editMode then ''
        source-file ${dirPath}/tmux.conf
      '' else
        builtins.readFile ./tmux.conf;
  };
}
