{ system, fetchzip }:

let

  version = "3.1.9";

  name = "pandoc-${version}";

  drvs = {

    "x86_64-linux" = fetchzip {
      inherit name;
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-amd64.tar.gz";
      sha256 = "18jcjfq2wmxmy03f2vxf7i9ls9li7rmypdrdb1gh9c5ypkrn2g4r";
    };

    "aarch64-linux" = fetchzip {
      inherit name;
      url = "https://github.com/jgm/pandoc/releases/download/${version}/pandoc-${version}-linux-arm64.tar.gz";
      sha256 = "1cxcp5vya7bi19f0jkwrkxqv8ppmxipi8nzh4gknrqpmp7w6hx8b";
    };

  };

in

(drvs.${system} or {}) // {
  meta.platforms = builtins.attrNames drvs;
}
