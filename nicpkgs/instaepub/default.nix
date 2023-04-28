{ lib
, substituteAll
, writers
, python3Packages
, pandoc
}:

lib.flip lib.makeOverridable {} (
  { consumerKey ? "badkey"
  , consumerSecret ? "verysecret"
  , username ? "nobody"
  , password ? "p@ssw0rd"
  , outputDir ? "."
  }:
  let
    src = substituteAll {
      src = ./instaepub.py;
      inherit consumerKey consumerSecret username password outputDir;
      inherit pandoc;
    };
  in
  writers.writePython3
    "instaepub"
    { libraries = with python3Packages; [ requests requests_oauthlib urllib3 ]; }
    src
)
