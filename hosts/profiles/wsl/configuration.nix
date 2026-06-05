{
  pkgs,
  username,
  ...
}:

{
  # WSL
  wsl = {
    enable = true;
    defaultUser = "${username}";
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

  # User
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    git
    jq
    kitty
    nix-prefetch-github
    gcc
    sops
    age
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.comic-shanns-mono
  ];

  # Flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Version
  system.stateVersion = "24.11";
}
