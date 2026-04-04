{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
			f = "yazi";
			m = "music";
			bash-update = "source ~/.bashrc";
    };
    
    sessionVariables = {
    		EDITOR = "nvim";
    		VISUAL = "nvim";
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
