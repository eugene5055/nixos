{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./customConfig
  ];

  nix = {
    settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      download-buffer-size = 524288000;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  swapDevices = [ ];
  zramSwap.enable = lib.mkForce false;

  hardware.cpu.intel.updateMicrocode = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl ];
  };

  glf.nvidia_config = {
    enable = true;
    laptop = false;
    nvidiaBusId = "PCI:1:0:0";
  };

  services.thermald.enable = true;
  services.lact.enable = true;
  services.flatpak.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  boot = {
    kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    kernelParams = [
      "intel_pstate=enable"
      "processor.max_cstate=1"
      "usbcore.autosuspend=-1"
      "nosplit_lock_mitigate"
      "split_lock_detect=off"
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"
      "mitigations=off"
      "nowwatchdog"
      "quiet"
      "splash"
      "loglevel=3"
    ];

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.edk2-uefi-shell.enable = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
      configurationLimit = 3;
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      lha = prev.runCommand "lha-dummy" {} ''
        mkdir -p $out/bin
        touch $out/bin/lha
        chmod +x $out/bin/lha
      '';
      lha-unfree = final.lha;
    })
  ];

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
    btop
    vulkan-tools
    intel-gpu-tools
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

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

  system.stateVersion = "26.05";
  glf.mangohud.configuration = "light";
}
