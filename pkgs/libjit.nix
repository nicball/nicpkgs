{ stdenv
, fetchFromSavannah
, autoreconfHook
, pkg-config
, bison
, flex
, texinfo
}:

stdenv.mkDerivation {
  pname = "libjit";
  version = "unstable-2020-04-17";
  src = fetchFromSavannah {
    repo = "libjit";
    rev = "942c988db170d98061a9e934fb3d7b618b7d5137";
    sha256 = "sha256-bnwVgFvfk4RcBg0/aqFt2tvFfT7s5axnlgr5ojYmj90=";
  };
  nativeBuildInputs = [ autoreconfHook pkg-config bison flex texinfo ];
}
