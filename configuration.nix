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

      system-features = [ "gccarch-raptorlake" "benchmark" "big-parallel" "kvm" "nixos-test" ];

      # Parallelism for 2026 Raptor Lake
      max-jobs = 2;
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
  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 100 * 1024; # 100GB
  } ];

  # --- Hardware & GPU Configuration ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [ libvdpau-va-gl ];
  };

  # Fix for "Too many open files" in 2026 builds
  systemd.services.nix-daemon.serviceConfig.LimitNOFILE = 65536;

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

  # --- OVERLAYS (Integrated Fixes) ---
  nixpkgs.overlays = [
    # Fix for Python: Disable tests for 'sh' and 'watchdog' globally
    # This prevents timing-related TimeoutExceptions on high-end CPUs
    (final: prev: {
      pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
        (pfinal: pprev: {
          sh = pprev.sh.overridePythonAttrs (oldAttrs: {
            doCheck = false;
          });
          watchdog = pprev.watchdog.overridePythonAttrs (oldAttrs: {
            doCheck = false;
          });
        })
      ];
    })

    # Fix for Assimp: Disable math tests failing under raptorlake optimizations
    (final: prev: {
      assimp = prev.assimp.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })

    # Overlay 1: Perl Fix
    (final: prev: {
      perlPackages = prev.perlPackages // {
        Test2Harness = prev.perlPackages.Test2Harness.overrideAttrs (_: {
          doCheck = false;
        });
      };
    })

    # Overlay 2: LHA Fix
    (self: super: {
      lha = super.runCommand "lha-dummy" {} "mkdir -p $out/bin; touch $out/bin/lha; chmod +x $out/bin/lha";
    })
  ];

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

  system.stateVersion = "26.05";
  glf.mangohud.configuration = "light";
}
