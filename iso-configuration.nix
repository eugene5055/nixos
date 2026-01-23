{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./modules/common.nix
  ];

  boot = {
    lanzaboote.enable = lib.mkForce false;
    plymouth.enable = lib.mkForce true;
    loader = {
      systemd-boot.enable = lib.mkOverride 1000 true;
      efi.canTouchEfiVariables = lib.mkForce false;
      timeout = lib.mkForce 10;
    };
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "ext4"
      "f2fs"
      "vfat"
      "xfs"
    ];
  };

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  networking.hostName = "nixos-live";
}
