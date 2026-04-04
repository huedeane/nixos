{ config, ... }:

{
  programs.yazi = {
    enable = true;
    
    theme = {
      flavor = {
        use = "catppuccin-frappe";
      };
    };
  };
  
  home.file.".config/yazi/yazi.toml".source = ./yazi.toml;
  home.file.".config/yazi/flavors".source = ./flavors;
}
