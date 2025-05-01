{ super, fetchpatch }:

super.wpa_supplicant.overrideAttrs (prev: {
  patches = prev.patches ++ [
    (fetchpatch {
      name = "reduce-signal-change-logs.patch";
      url = "https://w1.fi/cgit/hostap/patch/?id=c330b5820eefa8e703dbce7278c2a62d9c69166a";
      hash = "sha256-5ti5OzgnZUFznjU8YH8Cfktrj4YBzsbbrEbNvec+ppQ=";
    })
  ];
})
