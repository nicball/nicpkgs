{ lib, config, ... }:

{
  options = {
    nic.fish = {
      enable = lib.mkEnableOption "fish";
    };
  };

  config = lib.mkIf config.nic.fish.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        # emacs style movements
        bind alt-left prevd-or-backward-word
        bind alt-right nextd-or-forward-word
        bind alt-backspace backward-kill-word
        bind alt-delete kill-word
        bind ctrl-left backward-token
        bind ctrl-right forward-token
        bind ctrl-backspace backward-kill-token
        bind ctrl-delete kill-token
        bind ctrl-alt-h backward-kill-word
      '';
    };
  };

}

