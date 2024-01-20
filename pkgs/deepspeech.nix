{ python39Packages, fetchurl, autoPatchelfHook, stdenv, system }:

with python39Packages;

buildPythonApplication rec {
  pname = "deepspeech";
  version = "0.9.3";
  src = fetchurl {
    "x86_64-linux" = {
      url = "https://files.pythonhosted.org/packages/d6/f3/75765fe49787f7ebead5e609801963323f47f05700fd9c78041abd9adaa1/deepspeech-0.9.3-cp39-cp39-manylinux1_x86_64.whl";
      sha256 = "e2e7295ba4997ab86b4fb1bd7a784319dfcdb508ce26638063515334c11fa05a";
    };
    "x86_64-darwin" = {
      url = "https://files.pythonhosted.org/packages/71/a2/3297556ce3f712b1f1dab947517d1307e6195fabd2d7589939cc023dbcca/deepspeech-0.9.3-cp39-cp39-macosx_10_10_x86_64.whl";
      sha256 = "e9251407bc9c51177739994941420d43afc18b972bb3f5296a2b1c11a2b92b06";
    };
  }.${system};
  format = "wheel";
  propagatedBuildInputs = [ numpy ];
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];
  doCheck = false;
  meta.platforms = lib.platforms.x86;
}
