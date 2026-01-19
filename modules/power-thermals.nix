{ config, pkgs, lib, ... }: {
  # --- Performance & Core Services ---
  powerManagement = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };

  services.thermald.enable = lib.mkDefault false;
  services.irqbalance.enable = lib.mkDefault true;
  services.system76-scheduler.enable = lib.mkDefault true;
  services.lact.enable = lib.mkDefault false;

  zramSwap.enable = lib.mkDefault true;
}
