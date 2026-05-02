{ config, ... }:
{
  services.dunst = {
    enable = true;
    settings = {
      global = {
        monitor = 0;
        follow = "keyboard";
        enable_posix_regex = false;

        width = "(300, 700)";
        height = 350;
        notification_limit = 5;
        origin = "bottom-center";
        offset = "0x100";

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;
        progress_bar_frame_width = 1;
        progress_bar_corner_radius = 0;
        progress_bar_corners = "all";

        icon_corner_radius = 0;
        icon_corner = "all";

        indicate_hidden = true;
        separator_height = 2;
        padding = 15;
        horizontal_padding = 15;
        text_icon_padding = 0;
        frame_width = 3;
        gap_size = 10;
        
        sort = true;
        idle_threshold = 0;
        layer = "overlay";
        force_xwayland = false;

        font = "ComicShannsMono Nerd Font Mono 12";
        line_height = 3;
        markup = "full";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = true;
        show_indicators = false;

        #icon_path =
        #icon_theme = Papirus
        enable_recursive_icon_lookup = true;

        sticky_history = true;
        history_length = 20;

        dmenu = "/usr/bin/dmenu -p dunst";
        browser = "/usr/bin/xdg-open";
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        
        corner_radius = 0;
        corners = "all";

        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
        ignore_dbusclose = false;
        

        #background =
        #foreground =
        #format =
        fullscreen = "show";
        min_icon_size = 32;
        max_icon_size = 64;
        #new_icon =
        icon_position = "left";
        #default_icon =
        #set_transient =
        #set_category =
        #timeout =
        #override_dbus_timeout =
        #urgency =
        override_pause_level = 0;
        #skip_display
        #history_ignore
        action_name = "default";
        word_wrap = true;
        ellipsize = "middle";
        alignment = "center";
        hide_text = false;

        frame_color = "#babbf1";
        separator_color = "#f4b8e4";
        background = "#303446";
        highlight = "#babbf1";
        format = "<span font_size='14pt'> <b>--- %s ---</b> </span>\\n%b";
      };

      urgency_low = {
        foreground = "#a6d189";
        frame_color = "#a6d189";
      };

      urgency_normal = {
        foreground = "#babbf1";
        frame_color = "#babbf1";
      };

      urgency_critical = {
        foreground = "#e78284";
        frame_color = "#e78284";
      };
    };
  };
}
