{ config, ... }:

{
  programs.firefox = {
    enable = true;
    
    #configPath = ".config/mozilla/firefox";
    profiles = {
      huedeane = {
        isDefault = true;
        name = "huedeane";
      };
    };


  };

  home.file.".mozilla/firefox/main".source = ./chrome;
}
