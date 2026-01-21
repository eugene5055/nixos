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
        renice = 0;
        ioprio = "off";
        desiredgov = "performance";
        softrealtime = "auto";
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 1; # RTX 5090 is card1; GameMode may still probe card0 when mapping NVIDIA index.
        nv_core_clock_mhz_offset = -1;
        nv_mem_clock_mhz_offset = -1;
        nv_powermizer_mode = 1; # Prefer maximum performance
      };
      custom = {
        start = "${pkgs.libnotify}/bin/notify-send 'GameMode Activated' 'Performance optimizations enabled'";
        end = "${pkgs.libnotify}/bin/notify-send 'GameMode Deactivated' 'Normal performance restored'";
      };
    };
  };

}
