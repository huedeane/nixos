{ config, ... };

{
  programs.yazi = {
    enable = true;
    
    theme = {
      flavor = {
        use = "catppuccin-frappe"
      };
    };
  };
}
