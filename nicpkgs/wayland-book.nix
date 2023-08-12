{ stdenv, fetchgit, mdbook-epub }:

stdenv.mkDerivation {
  pname = "wayland-book";
  version = "unstable-2022-12-12";
  src = fetchgit {
    url = "https://git.sr.ht/~sircmpwn/wayland-book";
    rev = "9023e006f51a37b4ee84b42966aeeaa4f6fd44c5";
    sha256 = "sha256-I8bhpzisH2veHdCtEBC06eIQrVZk8BDvWhb8JDdWiwg=";
  };
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase = ''
    runHook preInstall
    mkdir $out
    mdbook-epub --standalone true
    mv book $out/
    runHook postInstall
  '';
}
