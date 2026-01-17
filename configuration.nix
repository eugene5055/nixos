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

      # Maximize 32-thread utilization
      max-jobs = "auto";
      cores = 0;
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # --- Hardware & GPU Configuration ---
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # i9-14900K QuickSync for background video tasks
      intel-vaapi-driver
      libvdpau-va-gl
    ];
  };

  glf.nvidia_config = {
    enable = true;
    laptop = false;
    nvidiaBusId = "PCI:1:0:0"; # RTX 5090
  };

  # Active Thermal Management for Raptor Lake Stability
  services.thermald.enable = true;
  services.lact.enable = true; # GPU Control
  services.flatpak.enable = true;

  # --- CPU Performance & Scheduling ---
  # Performance governor is vital for Intel Thread Director efficiency
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
      "mitigations=off"           # Extreme 14900K performance
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

  # CCache to speed up subsequent source updates
  programs.ccache.enable = true;

  # --- System Environment & Gaming ---
  environment.systemPackages = with pkgs; [
    nvtopPackages.full      # Monitor Intel iGPU + NVIDIA simultaneously
    btop                   # Visual P/E-core usage
    vulkan-tools
    intel-gpu-tools        # For intel_gpu_top
  ];

  programs.steam = {
    enable = true;
    protontricks.enable = true;
  };

  # Moza Racing Hardware Support
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
  '';

  # --- File Systems & Users ---
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

  nixpkgs.overlays = [
    (self: super: {
      lha = super.runCommand "lha-dummy" {} "mkdir -p $out/bin; touch $out/bin/lha; chmod +x $out/bin/lha";
    })
  ];

  system.stateVersion = "26.05";
  glf.mangohud.configuration = "light";
}
