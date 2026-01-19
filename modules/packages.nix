{ config, pkgs, lib, ... }: {
  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    # Web Browsers
    google-chrome

    # Gaming & Windows Compatibility
    lutris
    bottles
    protonup-qt
    mangohud
    goverlay
    vulkan-tools
    winetricks
    wineWowPackages.staging
    dxvk
    vkd3d

    # System & Monitoring
    nvtopPackages.full
    btop
    htop
    intel-gpu-tools
    sbctl

    # Performance tools
    linuxPackages.cpupower
    msr-tools

    # Notifications
    libnotify
  ];
}
