{ config, textfox, ...}

{
  imports = [
    textfox.homeManagerModules.default
  ];

  textfox = {
    enable = true;

    profiles = ["yj4hf6py"];
    #config = {
        # Optional config
    #};
  };
 } 
