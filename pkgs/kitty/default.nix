{ wrapDerivationOutput
, substituteAll
, super
, nicpkgs-scale
}:

let
  config = substituteAll {
    src = ./kitty.conf;
    fontSize = builtins.ceil (nicpkgs-scale * 12);
  };
in

wrapDerivationOutput super.kitty "bin/kitty" ''
  --add-flags '--config ${config}' \
  --prefix PATH : "$out/bin"
'' // {
  inherit (super.kitty) terminfo;
}
