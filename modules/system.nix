{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.fwupd.enable = true;


  documentation = {
    enable = true;
    doc.enable = false;
    man.enable = true;
    dev.enable = false;
    nixos.enable = false;
  };
}
