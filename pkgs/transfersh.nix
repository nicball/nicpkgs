{ buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "transfer.sh";
  version = "1.4.0";
  src = fetchFromGitHub {
    owner = "dutchcoders";
    repo = "transfer.sh";
    rev = "v1.4.0";
    sha256 = "sha256-8XMeLIhVWqXBeQToVSyLxEBgLVhCZ+kAf96Cti5e04U=";
  };
  vendorHash = "sha256-d7EMXCtDGp9k6acVg/FiLqoO1AsRzoCMkBb0zen9IGc=";
}
