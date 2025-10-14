{ lib, config, pkgs, ... }:

{
  options = {
    nic.greetd = {
      enable = lib.mkEnableOption "greetd";
      auto-login = {
        enable = lib.mkEnableOption "automatic login";
        user = lib.mkOption {
          type = lib.types.str;
        };
        start-command = lib.mkOption {
          type = lib.types.str;
          description = "command to start the shell";
        };
      };
    };
  };

  config = lib.mkIf config.nic.greetd.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd}/bin/agreety --cmd fish";
        };
      } // lib.optionalAttrs config.nic.greetd.auto-login.enable {
        initial_session = with config.nic.greetd.auto-login; {
          command = start-command;
          inherit user;
        };
      };
    };
  };

}
