{ config, ... }:

{
  programs.kitty = {
    enable = true;

    # Font
    font = {
      name = "ComicShannsMono Nerd Font Mono";
      size = 14.0;
    };

    settings = {
      # Terminal opacity and blur
      background_opacity          = "1.0";
      background_blur             = 1;

      # Cursor customization
      cursor_shape                = "beam";
      cursor_blink_interval       = 0;
      cursor_stop_blinking_after  = 0;
      shell_integration           = "no-cursor";

      # Scrollback settings
      wheel_scroll_multiplier     = "3.0";

      # Mouse settings
      mouse_hide_wait             = -1;
      focus_follows_mouse         = true;

      # Window layout settings
      remember_window_size        = true;
      initial_window_width        = 1200;
      initial_window_height       = 750;
      enabled_layouts             = "tall";
      window_border_width         = "1.5";
      window_padding_width        = 5;
      window_margin_width         = "2 10 2 10";
      placement_strategy          = "center";
      box_drawing_scale           = "1, 1, 1, 1";

      # Tab bar customization
      tab_bar_style               = "powerline";
      tab_powerline_style         = "slanted";
      tab_bar_edge                = "top";

      # Options
      detect_urls                 = true;
    };

    # Themes
    extraConfig = ''
      include ./theme/catppuccin-frappe-theme.conf
    '';

  };

  home.file.".config/kitty/themes/catppuccin-frappe-theme.conf".source = ./themes/catppuccin-frappe-theme.conf;
}
