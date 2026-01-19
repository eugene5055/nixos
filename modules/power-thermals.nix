{ config, pkgs, lib, ... }: {
  # --- Performance & Core Services ---
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "performance";
  };

<<<<<<< Updated upstream
  services.thermald.enable = false;
  services.irqbalance.enable = true;
  services.system76-scheduler.enable = true;
  services.lact.enable = false;
=======
  services.thermald.enable = true;
  services.lact.enable = true;
>>>>>>> Stashed changes

  zramSwap.enable = true;
}
