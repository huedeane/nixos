{ ... }:

{
  # System-level rather than home-manager: Steam needs 32-bit graphics/audio, controller udev
  # rules (hardware.steam-hardware, enabled by this module) and optional firewall ports.
  # Also wraps Steam's FHS env with the system graphics drivers and fonts, and installs steam-run.
  programs.steam = {
    enable = true;
  };
}
