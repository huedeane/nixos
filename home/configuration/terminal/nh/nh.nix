{
  config,
  ...
}:
{
  programs.nh = {
    enable = true;
    flake = "${config.xdg.configHome}/nixos";

    # Only cleans user profiles (home-manager generations); system generations need sudo
    clean = {
      enable = true;
      dates = "weekly";
      extraArgs = [
        "--keep"
        "5"
        "--keep-since"
        "7d"
      ];
    };
  };
}
