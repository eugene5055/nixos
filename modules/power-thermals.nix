{ config, pkgs, lib, ... }: {
  # --- Performance & Core Services ---
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

  services.thermald.enable = false;
  services.irqbalance.enable = true;
  services.system76-scheduler.enable = true;
  services.lact.enable = false;

  zramSwap.enable = true;
}
