{ config, pkgs, lib, ... }: {
  # --- Performance & Core Services ---
  powerManagement = {
    enable = false;
    cpuFreqGovernor = "schedutil";
  };

  services.thermald.enable = true;
  services.lact.enable = false;

  zramSwap.enable = true;
}
