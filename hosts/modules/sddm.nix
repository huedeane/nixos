{ pkgs, ... }: 
let
  sddm-theme = pkgs.callPackage ../../derivations/sddm-theme.nix {};
in 
{
  environment.systemPackages = [
    sddm-theme
  ];

  services.displayManager = {
    sddm = {
      wayland.enable = true;
      enable = true;
      package = pkgs.kdePackages.sddm;

      theme = "sddm-theme";
      extraPackages = [
        sddm-theme
      ];
    };
    autoLogin = {
      enable = false;
      user = "huedeane";
    };
  };
}
