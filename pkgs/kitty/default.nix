{ wrapDerivationOutput
, super
}:

wrapDerivationOutput super.kitty "bin/kitty" ''
  --add-flags '--config ${./kitty.conf}'
'' // {
  inherit (super.kitty) terminfo;
}
