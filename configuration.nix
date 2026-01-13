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
    # inputs.lanzaboote.nixosModules.lanzaboote
  ];

  # Nix Package Manager Optimization
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
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
  # hardware.opengl was renamed to hardware.graphics in NixOS 24.11+
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Standard for Steam/Wine compatibility
  };

  glf.nvidia_config = {
    enable = true;
    laptop = false;
    nvidiaBusId = "PCI:1:0:0"; # RTX 5090
  };

  # Services & Performance
  services.lact.enable = true;
  services.flatpak.enable = true;

  # Kernel & Boot
  boot = {
    kernelParams = [
      "amdgpu.ppfeaturemask=0xffffffff"
      "nosplit_lock_mitigate"
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
      "nvidia-drm.fbdev=1"
    ];

    # Lanzaboote Secure Boot Configuration
    # systemd-boot.enable must be false; lanzaboote handles the stub generation
    loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };

    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };
  };

  # Gaming & Steam Configuration
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true; # Automatically includes gamescope
    protontricks.enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;

    # Extra packages for monitoring and local utilities
    extraPackages = with pkgs; [ mangohud ];
  };

  programs.gamemode = {
    enable = true;
    settings.cpu.governor = "ignore";
  };

  # System Environment
  environment.systemPackages = with pkgs; [
    sbctl # Secure Boot management
    nvtopPackages.nvidia
    vulkan-tools
  ];

  # Moza Racing Hardware Support
  services.udev.extraRules = ''
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
  '';

  # Desktop Environment
  glf.environment = {
    type = "plasma";
    edition = "standard";
  };

  # User & Localization
  users.users.radean = {
    isNormalUser = true;
    description = "Radean";
    extraGroups = [ "networkmanager" "wheel" "dialout" ]; # "video" and "gamemode" removed (handled by uaccess/systemd)
  };

  networking = {
    hostName = "GLF-OS";
    networkmanager.enable = true;
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  fonts.packages = with pkgs; [
    corefonts
    vista-fonts
    noto-fonts-color-emoji
  ];

  # System State
  system.stateVersion = "26.05";
  glf.mangohud.configuration = "disabled";

}
