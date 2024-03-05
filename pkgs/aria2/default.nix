{ lib
, wrapDerivationOutput
, writeText
, super
, server-mode ? false
, dir ? "."
, log ? "${dir}/.log"
, session ? "${dir}/.session"
, rpc-secret ? "p@ssw0rd"
, bt-tracker ? "${builtins.readFile ./bt-trackers.txt}"
}:

let

  aria2Config = writeText "aria2.conf" ''
    ${lib.optionalString server-mode ''
      quiet
      dir=${dir}
      log=${log}
      input-file=${session}
      save-session=${session}
      save-session-interval=3600
      log-level=warn
      enable-rpc=true
      rpc-listen-all=true
      rpc-secret=${rpc-secret}
    ''}

    continue
    file-allocation=falloc
    max-concurrent-downloads=16
    split=16
    max-connection-per-server=16
    min-split-size=1M
    max-overall-upload-limit=1M
    max-tries=0
    retry-wait=1
    
    bt-tracker=${bt-tracker}
  '';

in

wrapDerivationOutput super.aria2 "bin/aria2c" ''
  --add-flags '--conf-path=${aria2Config}'
''
