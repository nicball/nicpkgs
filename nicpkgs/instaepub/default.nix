{ lib
, substituteAll
, writers
, python3Packages
, pkgs
}:

{ consumerKey ? "badkey"
, consumerSecret ? "verysecret"
, username ? "nobody"
, password ? "p@ssw0rd"
, outputDir ? "."
, autoArchive ? false
, pandoc ? pkgs.pandoc
}:

let

  src = substituteAll {
    src = ./instaepub.py;
    inherit consumerKey consumerSecret username password outputDir;
    autoArchive = if autoArchive then "True" else "False";
    inherit pandoc;
  };

in

writers.writePython3
  "instaepub"
  { libraries = with python3Packages; [ requests requests_oauthlib urllib3 ]; }
  src
