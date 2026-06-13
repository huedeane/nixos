{ pkgs, lib, config, editMode, ... }:
let
  dirPath = "${config.home.homeDirectory}/.config/nixos/home/configuration/terminal/tmux";
in
{
  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      yank
      {
        plugin = catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'frappe'
          set -g @catppuccin_window_status_style 'rounded'
        '';
      }
      resurrect
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '30'
        '';
      }
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
