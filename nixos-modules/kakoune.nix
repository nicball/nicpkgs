{ lib, pkgs, config, ... }:

let
  kak-with-perl = pkgs.wrapDerivationOutput pkgs.kakoune-unwrapped "bin/kak" ''
    --prefix PATH : "${lib.getBin pkgs.perl}/bin"
  '';
  kakoune-lsp-base = pkgs.rustPlatform.buildRustPackage rec {
    pname = "kakoune-lsp";
    version = "17.1.2";
    src = pkgs.fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-NZDp98Ne6z7DlJ2vZiqGzw5ukusOkEjb+eyvmxB+IKI=";
    };
    cargoHash = "sha256-QonOqdcdp1vbxzLnF46X0DLVay2Up1LvHZ/ZZ04LqlE=";
    buildInputs = with pkgs; [ perl makeWrapper ];
  };
  kakoune-lsp = pkgs.wrapDerivationOutput kakoune-lsp-base "bin/kak-lsp" ''
    --add-flags '--config ${./kakoune-lsp-config.toml}';
  '';
  my-plugins = pkgs.runCommand "my-kakoune-plugins" {} ''
    mkdir -p $out/share
    cp -r ${./kakoune-plugins} $out/share/kak
  '';
  package = pkgs.wrapKakoune kak-with-perl {
    plugins = with pkgs.kakounePlugins; [
      parinfer-rust
      kakoune-state-save
      kakoune-lsp
      kak-ansi
      my-plugins
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
