{ super, rofi-unwrapped, replaceVars, nicpkgs-scaling, makeBinaryWrapper }:

super.rofi.override {
  theme = replaceVars ./theme.rasi {
      fontSize = builtins.ceil (12 * nicpkgs-scaling);
  };
  rofi-unwrapped = rofi-unwrapped.overrideAttrs (final: prev: {
    nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [ makeBinaryWrapper ];
    postInstall = (prev.postInstall or "") + ''
      # when no mode matches the query, the first one is used
      wrapProgram $out/bin/rofi --add-flags '-modes combi -combi-modes run,drun,window'
    '';
  });
}
