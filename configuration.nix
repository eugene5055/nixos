{ inputs, config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./customConfig
  ];

  # --- Nix Package Manager & Optimization Settings ---
  nix = {
    settings = {
      substituters = [ "https://nix-community.cachix.org" ];
      trusted-public-keys = [ "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" ];
      experimental-features = [ "nix-command" "flakes" ];

      # 14900K Optimization: Whitelist the raptorlake feature for local builds
      system-features = [ "gccarch-raptorlake" "benchmark" "big-parallel" "kvm" "nixos-test" ];

      # --- MEMORY STABILITY FIXES ---
      # Limit to 1 package at a time to prevent 100GB swap from "thrashing"
      max-jobs = 1;
      # Allow that 1 package to use all 32 threads for speed
      cores = 0;

      auto-optimise-store = true;
      download-buffer-size = 524288000;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # --- SWAP CONFIGURATION (2026 Stability) ---
  # Ensures you always have breathing room for massive Raptor Lake source builds
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 100 * 1024; # 100GB
  } ];

  # --- Hardware & GPU Configuration ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  glf.nvidia_config = {
    enable = true;
    laptop = false;
    nvidiaBusId = "PCI:1:0:0"; # RTX 5090
  };

  services.thermald.enable = true;
  services.lact.enable = true;
  services.flatpak.enable = true;
  powerManagement.cpuFreqGovernor = "performance";

  # --- Kernel & Boot ---
  boot = {
    kernelParams = pkgs.lib.mkForce [
      "usbcore.autosuspend=-1"
      "nosplit_lock_mitigate"
      "split_lock_detect=off"
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"
      "mitigations=off"
      "nowatchdog"
      "quiet"
      "splash"
      "loglevel=3"
      "lsm=landlock,yama,bpf"
    ];

    kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

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

  # --- Global Raptor Lake Optimization ---
  nixpkgs.hostPlatform = {
    system = "x86_64-linux";
    gcc.arch = "raptorlake";
    gcc.tune = "raptorlake";
  };

  programs.ccache.enable = true;

  # --- System Environment & Gaming ---
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

  # --- OVERLAYS (Integrated Fixes) ---
  nixpkgs.overlays = [
    # Perl Test2Harness fix for Raptor Lake concurrency failures
    (final: prev: {
      perlPackages = prev.perlPackages // {
        Test2Harness = prev.perlPackages.Test2Harness.overrideAttrs (_: {
          doCheck = false;
        });
      };
    })
    # Existing lha dummy fix
    (self: super: {
      lha = super.runCommand "lha-dummy" {} "mkdir -p $out/bin; touch $out/bin/lha; chmod +x $out/bin/lha";
    })
  ];

  system.stateVersion = "26.05";
  glf.mangohud.configuration = "light";
}
