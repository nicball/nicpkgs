{ writeShellApplication }:

writeShellApplication {
  name = "swayexec";
  text = builtins.readFile ./swayexec.sh;
}
