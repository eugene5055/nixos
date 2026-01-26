{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./modules/common.nix
  ];

}
