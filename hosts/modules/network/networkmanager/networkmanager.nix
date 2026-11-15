{ ... }:

{
  networking.networkmanager = {
    enable = true;
    # Probe for real internet on each link. A link that fails gets its default route
    # demoted, so a plugged-in but dead ethernet no longer wins over a working hotspot.
    settings.connectivity = {
      uri = "http://nmcheck.gnome.org/check_network_status.txt";
      interval = 10;
    };
  };
}
