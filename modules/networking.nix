{ config, pkgs, lib, ... }: {
  # --- Networking & Localization ---
  networking = {
    hostName = lib.mkDefault "nixos";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
    nameservers = [ "1.1.1.1" "8.8.8.8" ];
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
}
