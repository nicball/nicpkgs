{ stdenv, cmake, wrapQtAppsHook, qtbase, qttools, qt5compat }:

let nv = <nicpkgs>.nv-sources.${stdenv.hostPlatform.system}.torrent-file-editor; in

stdenv.mkDerivation (self: {
  inherit (nv) pname version src;
  nativeBuildInputs = [ cmake wrapQtAppsHook ];
  buildInputs = [ qtbase qttools qt5compat ];
  cmakeFlags = [ "-DQT6_BUILD=ON" "-DCMAKE_BUILD_TYPE=Release" ];
})
