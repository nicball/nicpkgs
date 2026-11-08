{ config, ... }:

{
  age.secrets.nicball-hashed-password.file = ./nicball-hashed-password.age;
  users.users.nicball.hashedPasswordFile = config.age.secrets.nicball-hashed-password.path;
}
