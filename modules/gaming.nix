{ config, pkgs, lib, ... }: {
  # --- Gaming Optimizations ---
  programs.steam = {
    enable = true;
    protontricks.enable = true;
    gamescopeSession.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # GameMode - automatic performance optimization for games
  programs.gamemode = {
    enable = true;
    enableRenice = true;
    settings = {
      general = {
        renice = 10;
        inhibit_screensaver = 0;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1; # Prefer maximum performance
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode Activated' 'Performance optimizations enabled'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode Deactivated' 'Normal performance restored'";
      };
    };
  };
}
