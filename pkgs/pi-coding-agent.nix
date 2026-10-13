{ lib
, nv-sources
, fetchurl
, buildNpmPackage
, fetchFromGitHub
, versionCheckHook
, writableTmpDirAsHomeHook
, ripgrep
, fd
, makeBinaryWrapper
, stdenvNoCC
}:

let
  version = lib.removePrefix "v" nv-sources.pi-coding-agent.version;
  model-data = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz";
    hash = "sha256-w+aUI7yrlxLzGn5bbTRIrjVq+EQ57GvHAfYm9uoWRTU=";
  };
in

buildNpmPackage {
  inherit (nv-sources.pi-coding-agent) pname src;
  inherit version;
  npmDepsHash = "sha256-P/KWhkvLjtpWRiwLCHu2iUVyI8nragSnQGWUQNsRhw8=";
  npmWorkspace = "packages/coding-agent";
  npmRebuildFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [
    makeBinaryWrapper
  ];
  buildPhase = ''
    runHook preBuild
    tar -xzf ${model-data} -C packages/ai/src/providers --strip-components 3 package/dist/providers/data
    npm run build:offline
    runHook postBuild
  '';
  postInstall = ''
    cp -r ./packages $out/lib/node_modules/pi-monorepo/
  '';
  postFixup = "wrapProgram $out/bin/pi --suffix PATH : ${ lib.makeBinPath [ ripgrep fd ] }";

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgram = "${placeholder "out"}/bin/pi";
  versionCheckProgramArg = "--version";
}
