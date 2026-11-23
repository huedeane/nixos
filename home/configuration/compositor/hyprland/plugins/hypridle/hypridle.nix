{ config, pkgs, ... }:
let
  ags = "${config.programs.ags.finalPackage}/bin/ags";
  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  dpms = action: "${hyprctl} dispatch 'hl.dsp.dpms({ action = \"${action}\" })'";
in
{
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        # The ags lock screen (widget/ags/src/features/lock-screen); every lock goes through
        # `loginctl lock-session`, which hypridle turns into this
        lock_cmd = "${ags} request lock";
        before_sleep_cmd = "${loginctl} lock-session";
        # One key press wakes the screens after sleep instead of two
        after_sleep_cmd = dpms "enable";
        # Hold off sleep until the session is really locked; hypridle only works that out by
        # itself for hyprlock
        inhibit_sleep = 3;
      };

      listener = [
        {
          timeout = 600;
          on-timeout = "${loginctl} lock-session";
        }
        {
          timeout = 1200;
          on-timeout = dpms "disable";
          on-resume = dpms "enable";
        }
      ];
    };
  };
}
