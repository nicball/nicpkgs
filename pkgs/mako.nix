{ super
, writeText
, nicpkgs-scale
}:

let
  scale = x: toString (builtins.ceil (nicpkgs-scale * x));
  config = writeText "mako-config" ''
    font=sans ${scale 12}
    background-color=#5e81acd6
    text-color=#eceff4
    width=${scale 300}
    height=${scale 100}
    padding=${scale 12}
    outer-margin=${scale 10}
    margin=0,0,${scale 10}
    border-size=0
    #border-radius=${scale 16}
  '';
in

super.mako.overrideAttrs (prev: {
  preFixup = prev.preFixup + ''
    gappsWrapperArgs+=(
      --add-flags '--config ${config}'
    )
  '';
})
