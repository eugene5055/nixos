{ inputs, config, pkgs, lib, ... }: {
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
    loader = {
      systemd-boot.enable = lib.mkForce true;
      efi.canTouchEfiVariables = lib.mkForce false;
    };
  };

  isoImage = {
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  networking.hostName = lib.mkDefault "nixos-live";
}
