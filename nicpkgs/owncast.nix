{ lib, buildGoModule, fetchFromGitHub, nixosTests, bash, which, ffmpeg, makeWrapper, coreutils }:

buildGoModule rec {
  pname = "owncast";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "owncast";
    repo = "owncast";
    rev = "v${version}";
    sha256 = "sha256-aDXXRe/CrA5JuUeGmsBLtESa6jRTfokV9uhycpik7mw=";
  };

  vendorSha256 = "sha256-abAZtBwSVHJlbjciKZmBvU7bz/3FoTKh4SkuJbfwsas=";

  propagatedBuildInputs = [ ffmpeg ];

  nativeBuildInputs = [ makeWrapper ];

  preInstall = ''
    mkdir -p $out
    cp -r $src/static $out
  '';

  postInstall = let

    setupScript = ''
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
