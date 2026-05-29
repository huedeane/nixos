{ config, lib, ... }:

{
  programs.git = {
    enable = true;
    ignores = [
      ".direnv"
      "*.swp"
      "*~"
      ".DS_Store"
    ];
    signing.format = null;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push = {
        autoSetupRemote = true;
        default = "current";
      };
      fetch = {
        prune = true;
        prunetags = true;
      };
      rerere.enabled = true;
      diff.algorithm = "histogram";
      credential.helper = "store";
      core.autocrlf = "input";
      submodule.recurse = true;
    };
    includes = [
      { path = "${config.xdg.configHome}/git/identity"; }
    ];
  };

  home.activation.gitCredentials = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    GITHUB_USERNAME=$(cat /run/user/1000/secrets/github_username)
    GITHUB_EMAIL=$(cat /run/user/1000/secrets/github_email)
    GITHUB_KEY=$(cat /run/user/1000/secrets/github_key)

    mkdir -p "${config.xdg.configHome}/git"
    cat > "${config.xdg.configHome}/git/identity" << EOF
    [user]
        name = $GITHUB_USERNAME
        email = $GITHUB_EMAIL
    EOF

    echo "https://$GITHUB_USERNAME:$GITHUB_KEY@github.com" > "$HOME/.git-credentials"
  '';
}
