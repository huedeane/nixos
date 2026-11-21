{
  config,
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
    ../../modules/application/printing/printing.nix
    ../../modules/application/steam/steam.nix
    ../../modules/boot/grub/grub.nix
    ../../modules/display/greetd/greetd.nix
    ../../modules/network/networkmanager/networkmanager.nix
    ../../modules/virtualisation/vfio/vfio.nix
  ]
  ++ lib.optional withSecrets ../../modules/storage/qnap-nas/qnap-nas.nix;

  # Bootloader (shared GRUB setup in hosts/modules/boot/grub)
  # "auto" picks a low mode on the 1440p monitors; first one the firmware offers wins
  boot.loader.grub.gfxmodeEfi = "2560x1440,1920x1080,auto";

  # The KVM switch unplugs both monitors, so Hyprland shuffles every window onto a
  # headless fallback output and back, which kills Firefox (wl_surface.attach error).
  # Pin the dGPU connectors as always-connected with their EDIDs, dumped from
  # /sys/class/drm/card1-DP-*/edid. Skipped in the iGPU entry, where the dGPU is the VM's
  # and the same connector names would force phantom outputs on the iGPU.
  hardware.firmware = [
    (pkgs.runCommand "monitor-edid" { } ''
      install -Dm444 ${./edid/dp-1.bin} $out/lib/firmware/edid/dp-1.bin
      install -Dm444 ${./edid/dp-2.bin} $out/lib/firmware/edid/dp-2.bin
    '')
  ];
  boot.kernelParams = lib.mkIf (!lib.elem "igpu" config.system.nixos.tags) [
    "drm.edid_firmware=DP-1:edid/dp-1.bin,DP-2:edid/dp-2.bin"
    "video=DP-1:e"
    "video=DP-2:e"
  ];

  # Networking
  networking = {
    hostName = "${hostname}";
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
    # No "input"/"uinput": they let any program read every keystroke (sudo password
    # included) or inject fake ones
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

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
