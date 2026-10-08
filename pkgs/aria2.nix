{ writeText
, super
, makeBinaryWrapper
}:

let config = writeText "aria2.conf" ''
  enable-rpc=true
  rpc-listen-all=true
  continue
  file-allocation=falloc
  max-concurrent-downloads=16
  split=16
  max-connection-per-server=16
  min-split-size=1M
  max-overall-upload-limit=1M
  max-tries=0
  retry-wait=1
''; in

super.aria2.overrideAttrs (prev: {
  nativeBuildInputs = (prev.nativeBuildInputs or []) ++ [ makeBinaryWrapper ];
  postInstall = (prev.postInstall or "") + ''
    wrapProgram $bin/bin/aria2c --add-flags '--conf-path=${config}'
  '';
})
