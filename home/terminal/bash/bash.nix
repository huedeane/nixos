{ config, hostname, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
			f = "yazi";
			m = "music";
			bash-update = "source ~/.bashrc";
			secret-edit = "nvim $HOME/.config/nixos/home/terminal/bash/data/secrets.json";
      hypr-update = "nvim $HOME/.config/nixos/home/compositor/hyprland/hyprland.conf";
    };
    
    initExtra = ''
      export NIXOS_HOST="${hostname}"
      export NIXOS_CONFIG="$HOME/.config/nixos"

		  # Functions
		  source ${./function/functions.sh}
		  
		  # PS1
		  source ${./function/ps1.sh}
		  
		  # Secrets
    	source ${./function/secrets.sh}
    
    '';
  };
}
