{ super, nicpkgs-scaling, replaceVars }:

let conf = replaceVars ./kitty.conf {
  fontSize = builtins.ceil (10 * nicpkgs-scaling);
}; in

super.kitty.overrideAttrs (final: prev: {
  postInstall = (prev.postInstall or "" ) + ''
    wrapProgram $out/bin/kitty --add-flags '--config ${conf}'
  '';
})
