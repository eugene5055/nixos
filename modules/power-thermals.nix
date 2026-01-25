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

  services.lact.enable = lib.mkDefault true;

  systemd.services.scx-lavd = {
    description = "Sched-ext scx_lavd scheduler";
    wantedBy = [ "multi-user.target" ];
    after = [ "sysinit.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.scx.full}/bin/scx_lavd";
      Restart = "on-failure";
      RestartSec = "2s";
    };
  };

  # Swap
  zramSwap.enable = lib.mkDefault true;
}
