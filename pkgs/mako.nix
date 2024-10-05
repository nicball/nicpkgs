{ super
, writeText
, nicpkgs-scaling
}:

let
  scaling = x: toString (builtins.ceil (nicpkgs-scaling * x));
  config = writeText "mako-config" ''
    font=sans ${scaling 12}
    background-color=#5e81acd6
    text-color=#eceff4
    width=${scaling 300}
    height=${scaling 100}
    padding=${scaling 12}
    outer-margin=${scaling 10}
    margin=0,0,${scaling 10}
    border-size=0
    #border-radius=${scaling 16}
  '';
in

super.mako.overrideAttrs (prev: {
  preFixup = prev.preFixup + ''
    gappsWrapperArgs+=(
      --add-flags '--config ${config}'
    )
  '';
})
