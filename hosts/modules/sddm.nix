{ pkgs, username,... }: 
let
  sddm-theme = pkgs.callPackage ../../derivations/sddm/sddm-theme.nix {};
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
      extraPackages = with pkgs; [
        sddm-theme
      ];
    };
    autoLogin = {
      enable = false;
      user = "${username}";
    };
  };
}
