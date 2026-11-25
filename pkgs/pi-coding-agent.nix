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
    hash = "sha256-1oMS7FdLyVnLf+4m2k9IdtBnrtm7vnbodjWeYNIpR0c=";
  };
in

buildNpmPackage {
  inherit (nv) pname src;
  inherit version;
  npmDepsHash = "sha256-V7fRy44X50tqfFewWQ/k5UjvUt+AoMOZkTw/v0bib6o=";
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
  # npm workspace symlinks in the output point into packages/ and apps/ which
  # don't exist there. Replace runtime deps with built content and
  # delete the rest.
  postInstall = ''
    local nm="$out/lib/node_modules/pi-monorepo/node_modules"

    # Replace workspace deps needed at runtime with real copies
    for ws in @earendil-works/chord:packages/chord \
              @earendil-works/pi-ai:packages/ai \
              @earendil-works/pi-agent-core:packages/agent \
              @earendil-works/pi-codemode:packages/codemode \
              @earendil-works/pi-durable:packages/durable \
              @earendil-works/pi-env:packages/env \
              @earendil-works/pi-mcp:packages/mcp \
              @earendil-works/pi-schema:packages/schema \
              @earendil-works/pi-telemetry:packages/telemetry \
              @earendil-works/pi-tui:packages/tui; do
      IFS=: read -r pkg src <<< "$ws"
      rm "$nm/$pkg"
      cp -r "$src" "$nm/$pkg"
    done

    # Delete remaining workspace symlinks
    find "$nm" -type l \( -lname '*/packages/*' -o -lname '*/apps/*' \) -delete

    # Clean up now-dangling .bin symlinks
    find "$nm/.bin" -xtype l -delete
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
