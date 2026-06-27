{ ... }:

{
  xdg.desktopEntries.android = {
    name = "Android";
    comment = "Launch Waydroid";
    exec = "sh -c 'systemctl start waydroid-container && uwsm app -- waydroid show-full-ui'";
    icon = "waydroid";
    type = "Application";
    categories = [ "Utility" ];
  };
}
