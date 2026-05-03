{ config, ... }:

{
  programs.git = {
    enable = true;

     ignores = [
      ".direnv"
      "*.swp"
      "*~"
      ".DS_Store"
    ];

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      push.default = "current";
      fetch.prune = true;
      fetch.prunetags = true;
      rerere.enabled = true;
      diff.algorithm = "histogram";
      credential.helper = "store";
      core.autocrlf = "input";
      submodule.recurse = true;
    };
  };
}


