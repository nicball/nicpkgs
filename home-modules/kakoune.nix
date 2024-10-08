{ lib, pkgs, config, ... }:

{
  options = {
    nic.kakoune = {
      enable = lib.mkEnableOption "kakoune";
    };
  };

  config = lib.mkIf config.nic.kakoune.enable {
    programs.kakoune = {
      enable = true;
      extraConfig = lib.readFile ../nixos-modules/kakoune-config/kakrc;
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
  };
}
