{ lib, pkgs, ... }:

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

  # Extra GRUB entry that boots to a text login instead of the login manager, as a fallback
  # if the greeter breaks
  specialisation.tty.configuration = {
    system.nixos.tags = [ "tty" ];
    # install-grub pastes this verbatim into `menuentry "<name>"`, so close the quote to
    # slip in a --class for the theme icon (same trick as the iGPU entry)
    boot.loader.grub.configurationName = ''TTY Login" --class "nixos'';
    # The login manager only starts with graphical.target, so stop at the text login
    boot.kernelParams = [ "systemd.unit=multi-user.target" ];
    # Kernel errors (e.g. the desktop iGPU's "Failed to create link encoder", which loads after
    # the prompt) printed over the login; they stay in `journalctl -k`
    boot.consoleLogLevel = 3;
    # greetd turns off the tty1 login prompt to take it over, which left a bare cursor here
    services.greetd.enable = lib.mkForce false;
    # nixpkgs only starts the tty1 login without a display manager, and GNOME still pulls in
    # a fallback LightDM unit (never started here, since it needs graphical.target)
    systemd.targets.getty.wants = [ "autovt@tty1.service" ];
    # Rebuilding from inside this entry must not make it the default GRUB entry
    system.build.installBootLoader = lib.mkForce (
      pkgs.writeShellScript "install-parent-bootloader" ''
        exec /nix/var/nix/profiles/system/bin/switch-to-configuration boot
      ''
    );
  };
}
