{ lib, pkgs, config, ... }:

let
  package = pkgs.kakoune.override {
    plugins = with pkgs.kakounePlugins; [
      parinfer-rust
      kakoune-state-save
      kakoune-lsp
      kak-ansi
      kak-ispc
      kak-rescript
      kak-nord
      kak-one-light
    ];
  };
in

{
  options = {
    nic.kakoune = {
      enable = lib.mkEnableOption "kakoune";
    };
  };

  config = lib.mkIf config.nic.kakoune.enable {
    environment = {
      variables.KAKOUNE_CONFIG_DIR = ./kakoune-config;
      systemPackages = [ package ];
    };
  };
}
