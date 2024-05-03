{ fetchFromGitHub
, buildNpmPackage
, esbuild
, stdenv, bash, ocaml, ocamlPackages, dune_3
}:

let
  version = "1.50.0";

  source = fetchFromGitHub {
    owner = "rescript-lang";
    repo = "rescript-vscode";
    rev = version;
    sha256 = "sha256-4b2Z94/CCvPge9qKmv8svUib8zJ9NEZ+FYeylgmkKBQ=";
  };

  analysis = stdenv.mkDerivation {
    pname = "rescript-editor-analysis";
    inherit version;
    src = source;
    nativeBuildInputs = [ ocaml dune_3 ocamlPackages.cppo ];
    buildPhase = ''
      dune build
      cp _build/install/default/bin/rescript-editor-analysis rescript-editor-analysis.exe
    '';
    installPhase = ''
      mkdir -p $out/bin
      mv rescript-editor-analysis.exe $out/bin
    '';
  };
in

buildNpmPackage rec {
  pname = "rescript-language-server";
  inherit version;
  src = source;
  sourceRoot = "${src.name}/server";
  npmDepsHash = "sha256-xxGELwjKIGRK1/a8P7uvUCKrP9y8kqAHSBfi2/IsebU=";
  postPatch = ''
    cp -r ${analysis}/bin analysis_binaries/linux
  '';
  buildPhase = ''
    runHook preBuild
    ${esbuild}/bin/esbuild src/cli.ts --bundle --sourcemap --outfile=out/cli.js --format=cjs --platform=node --loader:.node=file --minify
    runHook postBuild
  '';
}
