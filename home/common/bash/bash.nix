{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    
    shellAliases = {
			f = "yazi"
			m = "music"
			bash-update = "source ~/.bashrc"
    };
    
    sessionVariables = {
    		EDITOR = "nvim";
    		VISUAL = "nvim";
    };
    
    initExtra = ''
    
    # Functions
    source ${./bash/function/function.sh}
    
    # PS1
    source ${./bash/function/ps1.sh}
    
    # Secrets
    source ${./bash/function/secrets.sh}
    
    '';
  }
}
