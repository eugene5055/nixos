{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- System Packages ---
  environment.systemPackages = with pkgs; [
    # Web Browsers
    google-chrome

    # Gaming & Windows Compatibility
    lutris
    protonplus
    gamescope
    mangohud
    vkbasalt
    vulkan-tools
    pkgs.pkgsi686Linux.vulkan-tools
    (pkgs.writeShellScriptBin "vulkaninfo32" ''
      exec ${pkgs.pkgsi686Linux.vulkan-tools}/bin/vulkaninfo "$@"
    '')
    winetricks
    wineWowPackages.staging
    dxvk
    vkd3d

    # System & Monitoring
    nvtopPackages.full
    btop
    intel-gpu-tools
    sbctl

    # Performance tools
    linuxPackages.cpupower
    msr-tools
    scx.full

    # Notifications
    libnotify
  ];
}
