{ config, pkgs, lib, ... }:

{
  services.factorio = {
    enable = true;
    admins = [ "nicball" ];
    description = "Nicball's Factorio Server";
    game-name = "MidyMidyFactorio";
    game-password = import ./private/factorio-password.nix;
    saveName = "server";
    lan = true;
    openFirewall = true;
    autosave-interval = 60;
    requireUserVerification = false;
    extraSettings = { auto_pause = true; autosave_slots = 100; };
    # mods =
    #   let
    #     modDir = ./factorio-mods;
    #     modList = lib.pipe modDir [
    #       builtins.readDir
    #       (lib.filterAttrs (k: v: v == "regular" && lib.hasSuffix ".zip" k))
    #       builtins.attrNames
    #     ];
    #     validPath = modFileName:
    #       builtins.path {
    #         path = modDir + "/${modFileName}";
    #         name = lib.strings.sanitizeDerivationName modFileName;
    #       };
    #     modToDrv = modFileName:
    #       pkgs.runCommand "copy-factorio-mods" {} ''
    #         mkdir $out
    #         ln -s '${validPath modFileName}' $out/'${modFileName}'
    #       ''
    #       // { deps = []; };
    #   in
    #     builtins.map modToDrv modList;
    package = pkgs.factorio-headless.overrideAttrs (self: super: {
      installPhase = super.installPhase + ''
        wrapProgram $out/bin/factorio --add-flags "--rcon-bind localhost:9790 --rcon-password 233"
      '';
      nativeBuildInputs = (super.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
    });
  };

  systemd.services.factorio-bot = {
    enable = false;
    description = "Factorio Matrix Bridge";
    after = [ "factorio.service" ];
    requires = [ "factorio.service" ];
    partOf = [ "factorio.service" ];
    wantedBy = [ "factorio.service" ];
    environment = config.networking.proxy.envVars // import ./private/factorio-bot-env.nix;
    serviceConfig = {
      ExecStart = "${pkgs.factorio-bot}/bin/midymidy-factorio-webservice";
      Restart = "always";
    };
  };
}
