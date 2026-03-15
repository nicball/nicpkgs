{ nv-sources
, buildNpmPackage
, esbuild
, stdenv, bash, ocaml, ocamlPackages, dune_3
}:

let

  inherit (nv-sources.rescript-language-server) version src;

  analysis = stdenv.mkDerivation {
    pname = "rescript-editor-analysis";
    inherit version src;
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
  inherit version src;
  sourceRoot = "${src.name}/server";
  npmDepsHash = "sha256-ossX/zc9/gQgHmdB6sQzG/w1zYFbskAFCkzCberbNf8=";
  postPatch = ''
    cp -r ${analysis}/bin analysis_binaries/linux
  '';
  buildPhase = ''
    runHook preBuild
    ${esbuild}/bin/esbuild src/cli.ts --bundle --sourcemap --outfile=out/cli.js --format=cjs --platform=node --loader:.node=file --minify
    runHook postBuild
  '';
}
