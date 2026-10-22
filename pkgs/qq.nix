{ super, curl, jq, cacert, runCommandLocal }:

super.qq.overrideAttrs {
  src = runCommandLocal "qq.deb" {
    outputHash = "sha256-Q2xl4d0oQi4SiiHL3bX+Ti5sB51/J/7CVB4BTTjMM24=";
    outputHashMode = "flat";
    nativeBuildInputs = [ curl jq cacert ];
  } ''
    signedUrl=$(
      curl -fsS --retry 3 -X POST "https://im.qq.com/http2rpc/gotrpc/noauth/trpc.qqntv2.urlsign.UrlSign/GetSign" \
        -H "Content-Type: application/json" \
        -H 'x-oidb: {"uint32_command":"0x9b8e","uint32_service_type":1}' \
        -d '{"url":"https://qqdl.gtimg.cn/qqfile/QQNTV2/9.9.36/release/9ee04bef/QQ_3.2.34_260924_amd64_01.deb"}' | jq -er '.data.url'
    )
    curl -fL --retry 3 -o "$out" "$signedUrl"
  '';
  version = "3.2.34-2026-09-24";
  postInstall = "wrapProgram $out/bin/qq --add-flag '--disable-seccomp-filter-sandbox'";
}
