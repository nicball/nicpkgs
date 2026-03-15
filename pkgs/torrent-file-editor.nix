{ stdenv, nv-sources, cmake, wrapQtAppsHook, qtbase, qttools, qt5compat }:

stdenv.mkDerivation (self: {
  inherit (nv-sources.torrent-file-editor) pname version src;
  nativeBuildInputs = [ cmake wrapQtAppsHook ];
  buildInputs = [ qtbase qttools qt5compat ];
  cmakeFlags = [ "-DQT6_BUILD=ON" "-DCMAKE_BUILD_TYPE=Release" ];
})
