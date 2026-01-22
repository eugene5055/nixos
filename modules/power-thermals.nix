{
  config,
  pkgs,
  lib,
  ...
}:
{
  # --- Performance & Core Services ---
  powerManagement = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };

  # Thermal and IRQ Management
  services.thermald.enable = lib.mkDefault false;
  services.irqbalance.enable = lib.mkDefault true;

  # Scheduler and GPU Control (LACT)
  services.system76-scheduler.enable = lib.mkDefault true;
  services.lact.enable = lib.mkDefault true;

  # Swap
  zramSwap.enable = lib.mkDefault true;
}
