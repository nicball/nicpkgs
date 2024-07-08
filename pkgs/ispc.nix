{ super
, fetchFromGitHub
}:

super.ispc.overrideAttrs rec {
  version = "1.24.0";
  src = fetchFromGitHub {
    owner = "ispc";
    repo = "ispc";
    rev = "v${version}";
    sha256 = "sha256-1Ns8w34fXgYrSu3XE89uowjaVoW3MOgKYV1Jb/XRj1Q=";
  };
  dontFixCmake = true;
}
