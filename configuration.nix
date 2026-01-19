{ inputs, config, pkgs, lib, ... }: {
  imports = [
    ./hardware-configuration.nix
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
}
