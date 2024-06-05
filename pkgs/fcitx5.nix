{ super, fetchFromGitHub }:

super.fcitx5.overrideAttrs rec {
  version = "5.1.10";
  src = fetchFromGitHub {
    owner = "fcitx";
    repo = "fcitx5";
    rev = version;
    hash = "sha256-rMtCzFe3imF/uY0kXM2ivyt11r5qNTNab7GkWzdeC/g=";
  };
}
