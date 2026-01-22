{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./modules/boot-kernel.nix
    ./modules/nix-settings.nix
    ./modules/nvidia.nix
    ./modules/bluetooth-udev.nix
    ./modules/power-thermals.nix
    ./modules/systemd.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/networking.nix
    ./modules/users.nix
    ./modules/packages.nix
    ./modules/gaming.nix
    ./modules/storage.nix
    ./modules/state.nix
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
