{ config, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
			m = "rmpc";
      g = "gitui";
			bash-update = "source ~/.bashrc";
			secret-edit = "nvim ${config.xdg.configHome}/nixos/home/configuration/terminal/bash/data/secrets.json";
      hypr-update = "nvim ${config.xdg.configHome}/nixos/home/configuration/compositor/hyprland/hyprland.conf";
    };
    
    initExtra = ''

		  # Functions
		  source ${./function/functions.sh}
		  
		  # PS1
		  source ${./function/ps1.sh}
		  
		  # Secrets
    	source ${./function/secrets.sh}
      
    '';
  };
}
