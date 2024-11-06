{ lib
, rustPlatform
, fetchFromGitHub
, replaceVars
, perl
, stdenv
}:

rustPlatform.buildRustPackage rec {
  pname = "kakoune-lsp";
  version = "18.0.3";
  src = fetchFromGitHub {
    owner = "kakoune-lsp";
    repo = "kakoune-lsp";
    rev = "v${version}";
    hash = "sha256-QGTNBWH/x9w54GDJ/U2r95lx/FENsr4nMRGDRR46wPg=";
  };
  cargoHash = "sha256-49Z4gZ2cGCAApAsWP98xgzZtwaxkIP8xi9LvXFFosnw=";
}
