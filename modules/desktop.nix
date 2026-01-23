{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- Display Manager & Desktop ---
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6 = {
    enable = true;
    enableQt5Integration = true;
  };

  # Remove unused KDE packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    elisa
    khelpcenter
  ];

  services.flatpak.enable = true;
  services.printing.enable = true;
}
