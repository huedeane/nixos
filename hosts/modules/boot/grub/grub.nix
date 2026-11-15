{ pkgs, ... }:

{
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      # Catppuccin with the "Booting in N seconds" countdown pinned to the bottom edge
      theme = pkgs.runCommand "catppuccin-mocha-grub-theme" { } ''
        cp -r ${
          pkgs.fetchFromGitHub {
            owner = "catppuccin";
            repo = "grub";
            rev = "main";
            sha256 = "sha256-jgM22pvCQvb0bjQQXoiqGMgScR9AgCK3OfDF5Ud+/mk=";
          }
        }/src/catppuccin-mocha-grub-theme $out
        chmod -R u+w $out
        sed -i 's/top = 82%/top = 100%-60/' $out/theme.txt
      '';
      # extraEntries always lands above the submenu and os-prober entries, so append
      # to grub.cfg after install-grub writes it. --class picks the theme icon
      extraInstallCommands = ''
        cat ${pkgs.writeText "grub-power-entries.cfg" ''
          # GRUB has no real separators; a no-op entry fakes one
          menuentry "────────────────────────────────────────" {
            true
          }
          menuentry "UEFI Firmware Settings" --class efi {
            fwsetup
          }
          menuentry "Reboot" --class restart {
            reboot
          }
          menuentry "Shutdown" --class shutdown {
            halt
          }
        ''} >> /boot/grub/grub.cfg
      '';
    };
    timeout = 15;
    efi.canTouchEfiVariables = true;
  };
}
