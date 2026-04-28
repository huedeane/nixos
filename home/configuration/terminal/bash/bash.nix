{ config, hostname, configHomeDir, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
			f = "yazi";
			m = "music";
			bash-update = "source ~/.bashrc";
			secret-edit = "nvim ${configHomeDir}/terminal/bash/data/secrets.json";
      hypr-update = "nvim ${configHomeDir}/compositor/hyprland/hyprland.conf";
    };
    
    initExtra = ''
      export NIXOS_HOST="${hostname}"
      export NIXOS_CONFIG="${config.xdg.configHome}/nixos"
      export NIXOS_CONFIGHOMEDIR="${configHomeDir}"

		  # Functions
		  source ${./function/functions.sh}
		  
		  # PS1
		  source ${./function/ps1.sh}
		  
		  # Secrets
    	source ${./function/secrets.sh}
    
    '';
  };
}
