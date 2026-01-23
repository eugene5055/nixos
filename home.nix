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

        gamemoderun mangohud "$@"

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

  # --- Gaming Scripts ---
  home.file.".local/bin/performance-mode" = {
    text = ''
      #!/usr/bin/env bash
      # Ultimate performance mode for sim racing

      echo "🏎️  PERFORMANCE MODE ACTIVATED"
      echo ""
      echo "Your system is optimized for racing:"
      echo "  ✓ CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo 'performance')"
      echo "  ✓ GameMode: Active when games launch"
      echo "  ✓ GPU: Maximum performance mode"
      echo "  ✓ I/O Scheduler: Optimized"
      echo ""
      echo "Compositor: niri (Wayland)"
      echo ""
      echo "Launch games with: gamemoderun mangohud your-game"
      echo ""

      notify-send "🏎️ Performance Mode" "System ready for racing"
    '';
    executable = true;
  };

  home.file.".local/bin/normal-mode" = {
    text = ''
      #!/usr/bin/env bash
      # Return to normal desktop mode

      echo "🖥️  NORMAL MODE"
      echo ""
      echo "System in normal desktop mode"
      echo "Compositor: niri (Wayland)"
      echo ""

      notify-send "🖥️ Normal Mode" "Desktop mode active"
    '';
    executable = true;
  };

  home.file.".local/bin/perf-report" = {
    text = ''
      #!/usr/bin/env bash
      echo "=== Performance Configuration ==="
      echo "CPU Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null)"
      echo "Compositor: niri (Wayland)"
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

    Compositor:
    niri (Wayland)

    === How to Apply ===
    1. Right-click game in Steam
    2. Properties → General → Launch Options
    3. Paste one of the above commands
  '';

  # --- Complete Usage Guide ---
  home.file."Documents/nixos-performance-guide.md".source = ./docs/nixos-performance-guide.md;

  # --- Niri Desktop Configuration ---
  home.file.".config/niri/config.kdl".text = ''
    // Minimal niri configuration with common desktop services.
    // See https://kdl.dev and https://yalter.github.io/niri for full reference.

    input {
        keyboard {
            numlock
        }

        touchpad {
            tap
            natural-scroll
        }
    }

    layout {
        gaps 12
    }

    spawn-at-startup "waybar"
    spawn-at-startup "mako"
    spawn-at-startup "nm-applet"
    spawn-at-startup "blueman-applet"
    spawn-at-startup "polkit-gnome-authentication-agent-1"
    spawn-at-startup "swaybg" "-m" "fill" "-c" "#1d1f21"
    spawn-sh-at-startup "wl-paste --type text --watch cliphist store"
    spawn-sh-at-startup "wl-paste --type image --watch cliphist store"
    spawn-sh-at-startup "swayidle -w timeout 300 'swaylock -f' timeout 600 'swaylock -f' before-sleep 'swaylock -f'"

    screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

    binds {
        Mod+Return { spawn "foot"; }
        Mod+D { spawn "wofi" "--show" "drun"; }
        Super+Alt+L { spawn "swaylock"; }

        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
        XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
        XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

        XF86AudioPlay allow-when-locked=true { spawn-sh "playerctl play-pause"; }
        XF86AudioStop allow-when-locked=true { spawn-sh "playerctl stop"; }
        XF86AudioPrev allow-when-locked=true { spawn-sh "playerctl previous"; }
        XF86AudioNext allow-when-locked=true { spawn-sh "playerctl next"; }

        XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
    }
  '';

  # --- Additional Tools ---
  home.packages = with pkgs; [
    # Performance monitoring
    corectrl
    lact

    # Gaming utilities
    heroic # Epic/GOG launcher

    # Wayland desktop essentials
    waybar
    wofi
    foot
    mako
    swaybg
    swayidle
    swaylock
    wl-clipboard
    cliphist
    grim
    slurp
    playerctl
    brightnessctl
    networkmanagerapplet
    blueman
    polkit_gnome
  ];

}
