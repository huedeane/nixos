{ ... }:

{
  programs.fzf = {
    enable = true;
    defaultOptions = [
      "--layout=reverse"
      "--height=80%"
      "--border=rounded"
      "--info=inline"
      "--preview-window=right:60%:wrap"
    ];
  };
}
