{ config, ... }:

{
  programs.firefox = {
    enable = true;
    
    configPath = ".config/firefox";
    profiles = {
      main = {
        isDefault = true;
        name = "main";
      };
    };
  };
}
