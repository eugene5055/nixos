modules/systemd.nix{ config, pkgs, lib, ... }: {
  # Systemd optimizations
  systemd = {
    services = {
      systemd-udev-settle.enable = false;
      NetworkManager-wait-online.enable = false;
    };
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
      DefaultTimeoutStartSec = "10s";
    };
  };
}
