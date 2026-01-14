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
      experimental-features = [ "nix-command" "flakes" ];
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
    enable32Bit = true; # Required for Steam and Wine
  };

  glf.nvidia_config = {
    enable = true;
    laptop = false;
    nvidiaBusId = "PCI:1:0:0"; # RTX 5090
  };

  # Performance and Overclocking Tools
  # LACT now supports Nvidia GPUs via NVML
  services.lact.enable = true;
  services.flatpak.enable = true;

  # Kernel & Boot
  boot = {
    kernelParams = [
      "nosplit_lock_mitigate"
      "nvidia-drm.fbdev=1" # Required for smooth console/Wayland transition
      "split_lock_detect=off"
    ];


    # Lanzaboote Secure Boot Configuration
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
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
  ];

  # Moza Racing Hardware Support
  # uaccess tag grants current user permission without needing 'dialout' or 'video' groups
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

  # Desktop Environment
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

  # System State - Do not change this unless you did a fresh install of 2026
  system.stateVersion = "26.05";
}
