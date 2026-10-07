{ super, nicpkgs-scaling, replaceVars }:

let
  scale = x: toString (builtins.ceil (nicpkgs-scaling * x));
  conf = replaceVars ./config {
    width = scale 300;
    height = scale 300;
    fontSize = scale 12;
    minIconSize = scale 36;
  };
in

super.dunst.overrideAttrs (final: prev: {
  postInstall = (prev.postInstall or "") + ''
    wrapProgram $out/bin/dunst --add-flags '--config ${conf}'
  '';
})
