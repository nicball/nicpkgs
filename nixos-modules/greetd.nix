{ lib, config, pkgs, ... }:

{
  options = {
    nic.greetd = {
      enable = lib.mkEnableOption "greetd";
      start-command = lib.mkOption {
        type = lib.types.str;
        description = "command to start the shell";
      };
    };
  };

  config = lib.mkIf config.nic.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.greetd}/bin/agreety --cmd fish";
        };
        initial_session = {
          command = config.nic.greetd.start-command;
          user = "nicball";
        };
      };
    };
  };

}
