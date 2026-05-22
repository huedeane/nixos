{ config, ... }:

{
  programs.nvf = {
    enable = true;

    settings.vim = {
      theme.enable = true;
    
      options = {
        tabstop = 2;
	      clipboard = "unnamedplus";
      };
  

    };

  };
}
