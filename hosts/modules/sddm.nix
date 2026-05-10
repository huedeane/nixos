{ pkgs, username,... }: 
let
  sddm-custom-theme = pkgs.callPackage ../../derivations/sddm/sddm-custom-theme.nix {};
in 
{
  environment.systemPackages = [
    sddm-custom-theme
  ];

  services.displayManager = {
    sddm = {
      wayland.enable = true;
      enable = true;
      package = pkgs.kdePackages.sddm;

      theme = "sddm-custom-theme";
      extraPackages = with pkgs; [
        sddm-custom-theme
      ];
    };
    autoLogin = {
      enable = false;
      user = "${username}";
    };
  };
}
