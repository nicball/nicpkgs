{ stdenv, fetchFromGitHub, cmake, wrapQtAppsHook, qtbase, qttools, qt5compat }:

stdenv.mkDerivation (self: {
  pname = "torrent-file-editor";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "torrent-file-editor";
    repo = "torrent-file-editor";
    rev = "v${self.version}";
    hash = "sha256-KS9HQcPMmd0HbpNlz4iupOPK1i6+nuB0mGxybK6tJoU=";
  };
  nativeBuildInputs = [ cmake wrapQtAppsHook ];
  buildInputs = [ qtbase qttools qt5compat ];
  cmakeFlags = [ "-DQT6_BUILD=ON" "-DCMAKE_BUILD_TYPE=Release" ];
})
