{ config, pkgs, lib, ... }: {
  # --- Performance & Core Services ---
  powerManagement = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = lib.mkDefault "performance";
  };

<<<<<<< HEAD
<<<<<<< Updated upstream
  services.thermald.enable = false;
  services.irqbalance.enable = true;
  services.system76-scheduler.enable = true;
  services.lact.enable = false;
=======
  services.thermald.enable = true;
  services.lact.enable = true;
>>>>>>> Stashed changes
=======
  services.thermald.enable = lib.mkDefault false;
  services.irqbalance.enable = lib.mkDefault true;
  services.system76-scheduler.enable = lib.mkDefault true;
  services.lact.enable = lib.mkDefault false;
>>>>>>> 60770a166adf54eac37c0f8e9dacd093c7dbf70e

  zramSwap.enable = lib.mkDefault true;
}
