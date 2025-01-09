{ lib
, substituteAll
, writers
, python3Packages
, pandoc
, pkgs
, consumer-key ? "badkey"
, consumer-secret ? "verysecret"
, username ? "nobody"
, password ? "p@ssw0rd"
, output-dir ? "."
, auto-archive ? false
, enable-pandoc ? true
, enable-instapaper ? true
}:

let

  src = substituteAll {
    src = ./instaepub.py;
    inherit username password;
    consumerKey = consumer-key;
    consumerSecret = consumer-secret;
    outputDir = output-dir;
    autoArchive = if auto-archive then "True" else "False";
    enablePandoc = if enable-pandoc then "True" else "False";
    enableInstapaper = if enable-instapaper then "True" else "False";
    inherit pandoc;
  };

in

writers.writePython3Bin
  "instaepub"
  { libraries = with python3Packages; [ requests requests_oauthlib urllib3 ]; }
  src
