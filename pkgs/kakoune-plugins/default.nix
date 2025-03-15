{ lib, runCommand, wrapDerivationOutput, callPackage, super }:

let

  makeKakounePlugin = name: files:
    runCommand name {} ''
      dir=$out/share/kak
      mkdir -p $dir
      ${lib.concatMapStringsSep "\n"
        (file: ''
          tdir=$(dirname $dir/'${file.path}')
          [ ! -e "$tdir" ] && mkdir -p "$tdir"
          cp -r '${file.source}' $dir/'${file.path}'
        '')
        files}
    '';

in (super.kakounePlugins or {}) // {

  kak-ispc = makeKakounePlugin "kak-ispc" [ {
    path = "autoload/ispc.kak";
    source = ./autoload/ispc.kak;
  } ];

  kak-racket = makeKakounePlugin "kak-racket" [ {
    path = "autoload/racket.kak";
    source = ./autoload/racket.kak;
  } ];

  kak-rescript = makeKakounePlugin "kak-rescript" [ {
    path = "autoload/rescript.kak";
    source = ./autoload/rescript.kak;
  } ];

  kak-nord = makeKakounePlugin "kak-nord" [ {
    path = "colors/nord.kak";
    source = ./colors/nord.kak;
  } ];

  kak-one-light = makeKakounePlugin "kak-one-light" [ {
    path = "colors/one-light.kak";
    source = ./colors/one-light.kak;
  } ];

  kakoune-lsp = wrapDerivationOutput super.kakoune-lsp "bin/kak-lsp" ''
    --add-flags '--config ${./kakoune-lsp-config.toml}';
  '';

}
