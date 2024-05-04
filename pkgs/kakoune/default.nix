{ lib
, kakoune-unwrapped
, kakounePlugins
, wrapKakoune
, wrapDerivationOutput
, stdenv, fetchFromGitHub, rustPlatform, perl, makeWrapper
}:

let
  pkg = wrapDerivationOutput kakoune-unwrapped "bin/kak" ''
    --set KAKOUNE_CONFIG_DIR ${./config} \
    --prefix PATH : "${lib.getBin perl}/bin"
  '';
  kakoune-lsp-base = rustPlatform.buildRustPackage rec {
    pname = "kakoune-lsp";
    version = "17.0.1";
    src = fetchFromGitHub {
      owner = pname;
      repo = pname;
      rev = "v${version}";
      sha256 = "sha256-uXKquAjfytUn/Q0kx+0BGRQTkVMQ9rMRnTCy622upag=";
    };
    cargoHash = "sha256-XnhYODMzqInwbgM8wveY048sljZ8OKw4hLYJG5h8Twc=";
    buildInputs = [ perl makeWrapper ];
  };
  kakoune-lsp = wrapDerivationOutput kakoune-lsp-base "bin/kak-lsp" ''
    --add-flags '--config ${./kakoune-lsp.toml}';
  '';
in

wrapKakoune pkg {
  plugins = with kakounePlugins; [
    parinfer-rust
    kakoune-state-save
    kakoune-lsp
    kak-ansi
  ];
} // {
  meta.mainProgram = "kak";
}
