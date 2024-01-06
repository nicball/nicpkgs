{ lib
, super
}:

lib.wrapDerivationOutput super.kitty "bin/kitty" ''
  --add-flags '--config ${./kitty.conf}'
'' // {
  inherit (super.kitty) terminfo;
}
