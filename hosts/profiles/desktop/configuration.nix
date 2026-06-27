{
  pkgs,
  hostname,
  username,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/sddm.nix
  ];

  # Bootloader
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      theme =
        pkgs.fetchFromGitHub {
          owner = "catppuccin";
          repo = "grub";
          rev = "main";
          sha256 = "sha256-jgM22pvCQvb0bjQQXoiqGMgScR9AgCK3OfDF5Ud+/mk=";
        }
        + "/src/catppuccin-mocha-grub-theme";
    };
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

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Desktop Environment: Hyprland
  programs.hyprland = {
    enable = true;
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
