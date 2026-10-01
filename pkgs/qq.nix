{ super, fetchurl }:

super.qq.overrideAttrs {
  src = fetchurl {
    url = "https://github.com/Rodert/qq-versions/releases/download/qq-packages-20260528-3e8913a2/QQ_3.2.29_260528_amd64_01.deb";
    hash = "sha256-HjgoB5ZzyUmUvA9HgNXYUoZHY5kgZZhi1J0cLyoZjiU=";
  };
  version = "3.2.29-2026-05-28";
}
