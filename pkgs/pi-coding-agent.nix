{ lib
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
  nv = <nicpkgs>.nv-sources.${stdenvNoCC.hostPlatform.system}.pi-coding-agent;
  version = lib.removePrefix "v" nv.version;
  model-data = fetchurl {
    url = "https://registry.npmjs.org/@earendil-works/pi-ai/-/pi-ai-${version}.tgz";
    hash = "sha256-U0PhY5vzQ73DNE3zrWwxwFpQtoutB6xrzhCJDUtrimE=";
  };
in

buildNpmPackage {
  inherit (nv) pname src;
  inherit version;
  npmDepsHash = "sha256-+gFyvrhkCsF99oNvs0gBmLXnDW0hWnZI/wFId7UbI6Q=";
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
