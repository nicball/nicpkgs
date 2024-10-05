{ wrapDerivationOutput
, substituteAll
, super
, nicpkgs-scaling
}:

let
  config = substituteAll {
    src = ./kitty.conf;
    fontSize = builtins.ceil (nicpkgs-scaling * 12);
  };
in

wrapDerivationOutput super.kitty "bin/kitty" ''
  --add-flags '--config ${config}' \
  --prefix PATH : "$out/bin"
'' // {
  inherit (super.kitty) terminfo;
}
