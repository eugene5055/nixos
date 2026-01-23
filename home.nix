{ config, pkgs, ... }:
{
  home.username = "radean";
  home.homeDirectory = "/home/radean";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;

  # --- Performance Environment Variables ---
  home.sessionVariables = {
    # Gaming performance
    MANGOHUD = "1";
    ENABLE_VKBASALT = "1";

    # NVIDIA optimizations
    __GL_SHADER_DISK_CACHE_PATH = "$HOME/.cache/nvidia";

    # Vulkan optimizations
    # Include both 64-bit and 32-bit ICDs so Proton/DXVK can initialize Vulkan.
    VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/nvidia_icd.i686.json";

    # Wine/Proton optimizations
    WINEFSYNC = "1";
    WINEESYNC = "1";
    WINE_RT_POLICY = "FF";
    WINE_RT_PRIO = "90";

    # Compilation
    MAKEFLAGS = "-j$(nproc)";
  };

  # --- Shell Configuration ---
  programs.bash = {
    enable = true;

    shellAliases = {
      # Performance monitoring
      "check-governor" = "grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor | head -1";
      "check-all-governors" = "grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor";
      "gpu-stats" = "nvidia-smi";
      "gpu-watch" = "watch -n 1 nvidia-smi";
      "temp-check" = "sensors";
      "io-scheduler" = "cat /sys/block/*/queue/scheduler";

      # Gaming shortcuts
      "steam-perf" = "gamemoderun steam";
      "lutris-perf" = "gamemoderun lutris";

      # System info
      "sys-info" =
        "echo 'CPU Governor:' && check-governor && echo 'I/O Scheduler:' && io-scheduler && echo 'GPU:' && nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu --format=csv,noheader";
    };

    # Useful functions
    bashrcExtra = ''
      # Launch any game with performance optimizations
      game() {

        ENABLE_VKBASALT=1 gamemoderun mangohud "$@"

      }
    '';
  };

  # --- MangoHud Configuration ---
  home.file.".config/MangoHud/MangoHud.conf".text = ''
    # Performance monitoring overlay
    fps
    fps_limit=0

    # CPU stats
    cpu_stats
    cpu_temp
    cpu_power
    cpu_mhz

    # GPU stats
    gpu_stats
    gpu_temp
    gpu_core_clock
    gpu_mem_clock
    gpu_power

    # Memory
    ram
    vram

    # Frame timing
    frame_timing=1
    frametime

    # Display settings
    position=top-left
    font_size=24
    background_alpha=0.5
    alpha=0.9

    # Toggle with Shift_R+F12
    toggle_fps_limit=Shift_R+F1
  '';

  home.file.".local/bin/perf-report" = {
    text = ''
      #!/usr/bin/env bash
      echo "=== Performance Configuration ==="
      echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
      echo "Compositor: $(qdbus org.kde.KWin /Compositor org.kde.kwin.Compositing.active 2>/dev/null && echo 'Enabled' || echo 'Disabled')"
      echo "I/O Scheduler (nvme2): $(cat /sys/block/nvme2n1/queue/scheduler 2>/dev/null | grep -o '\[.*\]' | tr -d '[]' || echo 'N/A')"
      echo "Huge Pages: $(grep HugePages_Total /proc/meminfo | awk '{print $2}')"
      echo "GameMode: $(systemctl --user is-active gamemoded 2>/dev/null || echo 'inactive')"
      echo ""
      nvidia-smi --query-gpu=name,temperature.gpu,power.draw,clocks.gr --format=csv,noheader 2>/dev/null
    '';
    executable = true;
  };

  # --- Steam Launch Options Reference ---
  home.file."Documents/steam-launch-options.txt".text = ''
    === Recommended Steam Launch Options ===

    For maximum performance (sim racing):
    gamemoderun mangohud PROTON_ENABLE_NVAPI=1 %command%

    For troubleshooting:
    gamemoderun PROTON_LOG=1 %command%

    For older games:
    gamemoderun PROTON_USE_WINED3D=1 %command%

    Disable compositor automatically:
    ~/.local/bin/toggle-compositor && %command%; ~/.local/bin/toggle-compositor

    === How to Apply ===
    1. Right-click game in Steam
    2. Properties → General → Launch Options
    3. Paste one of the above commands
  '';

  # --- Complete Usage Guide ---
  home.file."Documents/nixos-performance-guide.md".source = ./docs/nixos-performance-guide.md;

  # --- Additional Tools ---
  home.packages = with pkgs; [
    # Performance monitoring
    corectrl
    lact

    # Gaming utilities
    heroic # Epic/GOG launcher
  ];

  # --- KDE Plasma Optimizations ---
  # Disable file indexing for performance
  home.file.".config/baloofilerc".text = ''
    [Basic Settings]
    Indexing-Enabled=false
  '';

}
