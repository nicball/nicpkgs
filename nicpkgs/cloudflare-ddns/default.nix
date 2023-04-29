{ writeShellApplication
, substituteAll
, curl
, jq
}:

{ authKey ? "badkey"
, authEmail ? "nonexistent@example.com"
, zoneName ? "badzone"
, recordName ? "badrecord"
, log ? ""
}:

let

  source = substituteAll {
    src = ./cloudflare-ddns.sh;
    inherit authKey authEmail zoneName recordName log;
  };

in

writeShellApplication {
  name = "cloudflare-ddns";
  runtimeInputs = [ curl jq ];
  text = "${builtins.readFile source}";
}
