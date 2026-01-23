{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- Display Manager & Desktop ---
  programs.niri.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    defaultSession = "niri";
  };

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.blueman.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  services.flatpak.enable = true;
  services.printing.enable = true;
}
