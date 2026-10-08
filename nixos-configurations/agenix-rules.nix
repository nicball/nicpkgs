let
  me = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+HdY4yK36CaemcVluXu9/7MZ7VZ9syTnVLz3FSqUkL nicball" ];
  nuc = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKZqZss9h6NxsmXc3kFA8UXlvaUsznvCkP0bttWdL/Ss nuc" ];
in

{
  "desktop/clash.yaml.age".publicKeys = me;
  "common/nicball-hashed-password.age".publicKeys = me ++ nuc;
  "common/wireless-psk.age".publicKeys = me ++ nuc;
}
