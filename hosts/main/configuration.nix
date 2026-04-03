{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  }

  # Networking
  networking = {
    hostName = "main";
    networkmanager.enable = true;
  }

  # Time zone
  time = {
    timeZone = "America/New_York";
  }

  # Select internationalisation properties.
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
    }
  }

  # X11
  services.xserver = {
    enable = true;
    xkb = {
      layout = "us";
      variant = "";
    }
  }

  # Printing
  services.printing.enable = true;

  # Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Account
  users.users.huedeane = {
    isNormalUser = true;
    description = "huedeane";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # Desktop Environment: hyprland
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland = {
      enable = true;
    };
  };

  # Desktop Environment: gnome
  services.xserver = {
    displayManager.gdm.enable = true;
    destkopManager.gnome.enable = true;
  }

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System Package
  environment.systemPackages = with pkgs; [
    git
  ];

  # System Fonts
  fonts.packages = with pkgs; [
    
  ];
  
  # Flake
  nix.settings.experimental-features = [ "nix-command" "flakes"];

  # Version
  system.stateVersion = "24.11";

}
