{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.programs.claude-code = {
    enable = true;
  };
}
