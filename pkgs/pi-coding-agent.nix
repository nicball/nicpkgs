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
    hash = "sha256-1XFe+oNMI7/fEKBCtJ307hacyZAAvxbXmY+rLVM7Rfg=";
  };
in

buildNpmPackage {
  inherit (nv) pname src;
  inherit version;
  npmDepsHash = "sha256-uHehffbEB2uU9U9uSpfWojzxvQyqeicbh/esCwk4neQ=";
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
  dontNpmPrune = true;
  preInstall = ''
    npm prune --omit=dev --no-save
  '';
  postInstall = ''
    cp -r ./packages $out/lib/node_modules/pi-monorepo/

    # apps/* (p2, p3) are npm workspaces but are not installed. Drop the
    # node_modules symlinks that point at them, plus any dangling .bin links.
    find $out/lib/node_modules/pi-monorepo/node_modules -maxdepth 1 -xtype l -delete
    find $out/lib/node_modules/pi-monorepo/node_modules/.bin -xtype l -delete
  '';
  postFixup = ''
    wrapProgram $out/bin/pi --prefix PATH : ${lib.makeBinPath [ ripgrep fd ]} \
      --set-default PI_SKIP_VERSION_CHECK 1 \
      --set-default PI_TELEMETRY 0
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgram = "${placeholder "out"}/bin/pi";
  versionCheckProgramArg = "--version";
}
