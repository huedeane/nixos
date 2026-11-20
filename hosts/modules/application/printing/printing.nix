{ pkgs, ... }:

{
  # CUPS with the open-source Brother laser driver (HL-2270DW). Without a matching driver,
  # udev-configure-printer only finds the generic PCL PPD and skips creating a queue.
  services.printing = {
    enable = true;
    drivers = [ pkgs.brlaser ];
  };

  # system-config-printer-applet (autostarted from Hyprland) owns com.redhat.NewPrinterNotification,
  # which udev-configure-printer calls to raise the "printer added" notification on hotplug.
  environment.systemPackages = [ pkgs.system-config-printer ];
}
