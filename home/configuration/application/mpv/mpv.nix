{ ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      # stay open on the last frame instead of exiting at end of file
      keep-open = "yes";
    };
  };
}
