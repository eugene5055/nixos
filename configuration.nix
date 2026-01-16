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
    ./customConfig
  ];

  # Nix Package Manager Settings
  nix = {
    settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Graphics & Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  glf.nvidia_config = {
    enable = true;
    laptop = false;
    nvidiaBusId = "PCI:1:0:0"; # RTX 5090
  };

  services.lact.enable = true;
  services.flatpak.enable = true;

  # Kernel & Boot
  boot = {
    kernelParams = [
      "nosplit_lock_mitigate"
      "nvidia-drm.fbdev=1"
      "split_lock_detect=off"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      # Adds EDK2 to the systemd-boot menu
      systemd-boot.edk2-uefi-shell.enable = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 3;
    };
  };

  # Gaming & Steam Configuration
  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  # System Environment
  environment.systemPackages = with pkgs; [
    nvtopPackages.nvidia
    vulkan-tools
    edk2-uefi-shell # Kept: allows access to the .efi binary for manual signing/tasks
  ];

  # Moza Racing Hardware Support
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
  '';

  fileSystems."/run/media/radean" = {
    device = "/dev/disk/by-uuid/de66f12c-d787-485d-a207-3590e64045ae";
    fsType = "btrfs";
    options = [ "defaults" "compress=zstd" "nofail" ];
  };

  glf.environment = {
    type = "plasma";
    edition = "standard";
  };

  # User & Localization
  users.users.radean = {
    isNormalUser = true;
    description = "Radean";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  networking = {
    hostName = "GLF-OS";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.overlays = [
  (self: super: {
    lha = super.runCommand "lha-dummy" {} "mkdir -p $out/bin; touch $out/bin/lha; chmod +x $out/bin/lha";
  })
];

  system.stateVersion = "26.05";
}
