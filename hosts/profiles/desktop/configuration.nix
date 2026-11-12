{
  lib,
  pkgs,
  hostname,
  username,
  inputs,
  withSecrets,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/sddm.nix
    ../../modules/vfio.nix
  ]
  ++ lib.optional withSecrets ../../modules/qnap-nas.nix;

  # Bootloader
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      # Catppuccin with Unifont swapped for ComicShannsMono; install-grub loadfonts every .pf2 in the theme
      theme =
        pkgs.runCommand "catppuccin-mocha-grub-theme-comic" { nativeBuildInputs = [ pkgs.grub2 ]; } ''
          cp -r ${
            pkgs.fetchFromGitHub {
              owner = "catppuccin";
              repo = "grub";
              rev = "main";
              sha256 = "sha256-jgM22pvCQvb0bjQQXoiqGMgScR9AgCK3OfDF5Ud+/mk=";
            }
          }/src/catppuccin-mocha-grub-theme $out
          chmod -R u+w $out
          grub-mkfont -s 24 -o $out/comic.pf2 \
            ${pkgs.nerd-fonts.comic-shanns-mono}/share/fonts/opentype/NerdFonts/ComicShannsMono/ComicShannsMonoNerdFontMono-Bold.otf
          sed -i 's/Unifont Regular 16/ComicShannsMono Nerd Font Mono Bold 24/' $out/theme.txt
          # Widen the menu so the longest entry still fits at the bigger font size
          sed -i 's/left = 50%-240/left = 50%-320/; s/width = 480/width = 640/' $out/theme.txt
        '';
      # "auto" picks a low mode on the 1440p monitors; first one the firmware offers wins
      gfxmodeEfi = "2560x1440,1920x1080,auto";
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

  # Networking
  networking = {
    hostName = "${hostname}";
    networkmanager.enable = true;
  };

  # Time zone
  time = {
    timeZone = "America/New_York";
  };

  # Internationalisation
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Polkit
  security.polkit.enable = true;

  # Printing
  services.printing.enable = true;

  # Audio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Mount
  services.udisks2.enable = true;

  # Android MTP (Pixel / phones over USB); systemd uaccess handles permissions
  services.gvfs.enable = true;

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
      "input"
      "uinput"
    ];
  };

  hardware.uinput.enable = true;

  services.udev.extraRules = ''
    KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';

  # Phone Integration: KDE Connect (opens TCP/UDP 1714-1764)
  programs.kdeconnect.enable = true;

  # Desktop Environment: Hyprland
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage =
      inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Desktop Environemtn: Gnome
  # services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    nix-prefetch-github
    gcc
    age
  ];

  # Graphic
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      pkgs.vulkan-loader
      pkgs.vulkan-validation-layers
    ];
  };

  # Virtualisation
  virtualisation = {
    waydroid = {
      enable = true;
      package = pkgs.waydroid-nftables;
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.comic-shanns-mono
  ];

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];

  # Version
  system.stateVersion = "24.11";
}
