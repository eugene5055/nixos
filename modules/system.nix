{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.fwupd.enable = true;


  documentation = {
    doc.enable = false;
    dev.enable = false;
    nixos.enable = false;
  };
}
