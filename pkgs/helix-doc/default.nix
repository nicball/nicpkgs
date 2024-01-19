{ lib, stdenv, fetchFromGitHub, fetchurl, mdbook-epub }:

stdenv.mkDerivation {
  pname = "helix-doc";
  version = "unstable-2023-08-11";
  src = fetchFromGitHub {
    owner = "helix-editor";
    repo = "helix";
    rev = "ee3171cc54052bc8d3569cc04bd9f6a57b43afca";
    sha256 = "sha256-EeMn5KYej0NmCf3ghOjq2s8axjaKfqurak5FzScGTO0=";
  };
  patches = [ ./gifs.patch ];
  dontConfigure = true;
  dontBuild = true;
  nativeBuildInputs = [ mdbook-epub ];
  installPhase =
    let
      imgs = [
        {
          name = "surround-demo.gif";
          path = fetchurl {
            url = "https://user-images.githubusercontent.com/23398472/122865801-97073180-d344-11eb-8142-8f43809982c6.gif";
            sha256 = "sha256-ShcKEV5V145mG/V9mgmy2Rk+esGaW6Yeg5TEC54cozI=";
          };
        }
        {
          name = "textobject-demo.gif";
          path = fetchurl {
            url = "https://user-images.githubusercontent.com/23398472/124231131-81a4bb00-db2d-11eb-9d10-8e577ca7b177.gif";
            sha256 = "sha256-cjYd/+0XEKeNp8GTECZmm6XxehSA64q3XBFCcBykUKU=";
          };
        }
        {
          name = "textobject-tree-sitter-demo.gif";
          path = fetchurl {
            url = "https://user-images.githubusercontent.com/23398472/132537398-2a2e0a54-582b-44ab-a77f-eb818942203d.gif";
            sha256 = "sha256-c8Lp8XN8er2N6WqAvUbydog8W+O9R8D/HQkwUEspZRg=";
          };
        }
        {
          name = "tree-sitter-nav-demo.gif";
          path = fetchurl {
            url = "https://user-images.githubusercontent.com/23398472/152332550-7dfff043-36a2-4aec-b8f2-77c13eb56d6f.gif";
            sha256 = "sha256-6HezXhqCb9JQ/94un/tM63W3FlLgpbrLLa5P3C2/OBs=";
          };
        }
        {
          name = "helix.svg";
          path = fetchurl {
            url = "https://repology.org/badge/vertical-allrepos/helix.svg";
            sha256 = "sha256-0DGhmsCcqUpZG0Bmz4j8RRyQS7GlyVwGC4YH7IYU48g=";
          };
        }
      ];
    in
    ''
      runHook preInstall
      cd book
      mkdir src/img
      ${lib.concatMapStrings (img: "cp '${img.path}' src/img/'${img.name}'\n") imgs}
      mkdir $out
      mdbook-epub --standalone true
      mv book/*.epub $out/
      runHook postInstall
    '';
}
