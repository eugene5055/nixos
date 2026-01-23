{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.fwupd.enable = true;

  nixpkgs.hostPlatform = lib.systems.examples.x86_64-v3;

  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    nixos.enable = false;
  };
}
