{ stdenv, fetchzip }:

let

  version = "3.9";

  name = "pandoc-${version}";

  drvs = {

    "x86_64-linux" = fetchzip {
      inherit name;
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
      hash = "sha256-zU/UCIBuBcGOLj6leXJebPzsa8oGC+JUAyhBqdzKdto=";
    };

  };

in

(drvs.${stdenv.hostPlatform.system} or {}) // {
  meta.platforms = builtins.attrNames drvs;
}
