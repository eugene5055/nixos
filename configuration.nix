{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
    ./hardware-configuration.nix
    ./modules/boot-kernel.nix
    ./modules/nix-settings.nix
    ./modules/system.nix
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

  nixpkgs.overlays = [ inputs.niri.overlays.niri ];

  programs.niri.enable = true;
}
