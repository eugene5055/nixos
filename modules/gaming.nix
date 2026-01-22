{
  config,
  pkgs,
  lib,
  ...
}:
{
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
        renice = -10;
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

  # Steam hardware udev rules (controllers/VR for lowest latency)
  hardware.steam-hardware.enable = true;

  # Gaming performance environment variables
  environment.variables = {
    WINEESYNC = "1";
    WINEFSYNC = "1";
    WINE_NTSYNC = "1";
    PROTON_USE_FSYNC = "1";
    PROTON_USE_NTSYNC = "1";
    PROTON_NO_ESYNC = "0";
    PROTON_NO_FSYNC = "0";
    vblank_mode = "0";
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";
  };
}
