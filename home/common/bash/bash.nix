{ config, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
			f = "yazi";
			m = "music";
			bash-update = "source ~/.bashrc";
			secret-edit = "nvim $HOME/.config/nixos/home/common/bash/data/secrets.json";
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
