{ lib, buildGoModule, fetchFromGitHub, nixosTests, bash, which, ffmpeg, makeWrapper, coreutils }:

buildGoModule rec {
  pname = "owncast";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "owncast";
    repo = "owncast";
    rev = "v${version}";
    sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  vendorSha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  propagatedBuildInputs = [ ffmpeg ];

  nativeBuildInputs = [ makeWrapper ];

  preInstall = ''
    mkdir -p $out
    cp -r $src/{static,webroot} $out
  '';

  postInstall = let

    setupScript = ''
      [ ! -d "$PWD/webroot" ] && (
        ${coreutils}/bin/cp --no-preserve=mode -r "${placeholder "out"}/webroot" "$PWD"
      )

      [ ! -d "$PWD/static" ] && (
        [ -L "$PWD/static" ] && ${coreutils}/bin/rm "$PWD/static"
        ${coreutils}/bin/ln -s "${placeholder "out"}/static" "$PWD"
      )
    '';
  in ''
    wrapProgram $out/bin/owncast \
      --run '${setupScript}' \
      --prefix PATH : ${lib.makeBinPath [ bash which ffmpeg ]}
  '';

  installCheckPhase = ''
    runHook preCheck
    $out/bin/owncast --help
    runHook postCheck
  '';

}
