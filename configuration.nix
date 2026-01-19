{ inputs, config, pkgs, lib, ... }: {



imports = [



  ./hardware-configuration.nix



];







# --- Boot & Kernel (Maximum Performance) ---



boot = {



  kernelPackages = lib.mkForce pkgs.linuxPackages_latest;







  # Aggressive performance kernel parameters



  kernelParams = [



    # CPU Performance



    "intel_pstate=active"



    "intel_pstate=no_hwp"



    "processor.max_cstate=1"



    "idle=poll"







    # USB & Latency



    "usbcore.autosuspend=-1"







    # Security mitigations (disabled for max performance)



    "nosplit_lock_mitigate"



    "split_lock_detect=off"



    "mitigations=off"



    "nospectre_v1"



    "nospectre_v2"



    "spec_store_bypass_disable=off"



    "tsx=on"



    "tsx_async_abort=off"



    "mds=off"







    # NVIDIA



    "nvidia-drm.modeset=1"



    "nvidia-drm.fbdev=1"



    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"



    "nvidia.NVreg_OpenRmEnableUnsupportedGpus=1"







    # System



    "nowatchdog"



    "nmi_watchdog=0"



    "quiet"



    "splash"



    "loglevel=3"



    "threadirqs"







    # OPTIONAL: Core isolation for sim racing (uncomment and adjust for your CPU)



    # Reserve last 4 cores for racing games - reduces jitter



    # "isolcpus=6,7,14,15"  # Adjust based on your CPU core count



  ];







  kernelModules = [ "tcp_bbr" ];







  # Performance-focused sysctl parameters



  kernel.sysctl = {



    # Network performance



    "net.core.netdev_max_backlog" = lib.mkForce 16384;



    "net.core.somaxconn" = lib.mkForce 8192;



    "net.core.rmem_max" = lib.mkForce 134217728;



    "net.core.wmem_max" = lib.mkForce 134217728;



    "net.ipv4.tcp_rmem" = lib.mkForce "4096 87380 134217728";



    "net.ipv4.tcp_wmem" = lib.mkForce "4096 65536 134217728";



    "net.ipv4.tcp_congestion_control" = lib.mkForce "bbr";



    "net.ipv4.tcp_fastopen" = lib.mkForce 3;



    "net.ipv4.tcp_mtu_probing" = lib.mkForce 1;



    "net.core.default_qdisc" = lib.mkForce "fq";







    # VM/Memory performance



    "vm.swappiness" = lib.mkForce 10;



    "vm.vfs_cache_pressure" = lib.mkForce 50;



    "vm.dirty_ratio" = lib.mkForce 10;



    "vm.dirty_background_ratio" = lib.mkForce 5;



    "vm.dirty_writeback_centisecs" = lib.mkForce 1500;







    # Huge pages for better game performance



    "vm.nr_hugepages" = lib.mkForce 2048;  # 2GB of huge pages







    # File system performance



    "fs.file-max" = lib.mkForce 2097152;



    "fs.inotify.max_user_watches" = lib.mkForce 524288;







    # Scheduler performance



    "kernel.sched_migration_cost_ns" = lib.mkForce 5000000;



    "kernel.sched_autogroup_enabled" = lib.mkForce 0;



    "kernel.nmi_watchdog" = lib.mkForce 0;



    "kernel.unprivileged_userns_clone" = lib.mkForce 1;







    # Gaming-specific



    "vm.max_map_count" = lib.mkForce 2147483642;



  };







  loader = {



    efi.canTouchEfiVariables = true;



    systemd-boot.enable = lib.mkForce false;



    timeout = 1;



  };







  lanzaboote = {



    enable = true;



    pkiBundle = "/var/lib/sbctl";



    configurationLimit = 3;



  };







  # Faster initrd



  initrd.systemd.enable = true;



  plymouth.enable = false;



};







nix.settings = {



  experimental-features = [ "nix-command" "flakes" ];



  auto-optimise-store = true;



  max-jobs = "auto";



  cores = 0;



  sandbox = true;



};







# --- NVIDIA Graphics (Maximum Performance) ---



services.xserver.videoDrivers = [ "nvidia" ];







hardware.graphics = {



  enable = true;



  enable32Bit = true;



  extraPackages = with pkgs; [



    libvdpau-va-gl



    nvidia-vaapi-driver



    libva-vdpau-driver



  ];



};







hardware.nvidia = {



  modesetting.enable = true;



  powerManagement.enable = false;



  powerManagement.finegrained = false;



  open = true;



  nvidiaSettings = true;



  package = config.boot.kernelPackages.nvidiaPackages.stable;



  forceFullCompositionPipeline = false;



};







# NVIDIA performance environment variables



environment.variables = {



  __GL_YIELD = "NOTHING";



  __GL_THREADED_OPTIMIZATION = "1";



  __GL_SYNC_TO_VBLANK = "0";



  __GL_SHADER_DISK_CACHE = "1";



  __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";



  KWIN_TRIPLE_BUFFER = "1";



  PROTON_ENABLE_NVAPI = "1";



};







# --- Bluetooth & Hardware Support ---



hardware.bluetooth = {



  enable = true;



  powerOnBoot = true;



  settings = {



    General = {



      Enable = "Source,Sink,Media,Socket";



      Experimental = true;



    };



  };



};







# Moza/Sim-Racing hardware support



services.udev = {



  packages = [ pkgs.game-devices-udev-rules ];







  # I/O Scheduler optimizations



  extraRules = ''



    # NVMe drives - use none scheduler for best performance



    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"







    # SATA/SAS drives - use mq-deadline



    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/scheduler}="mq-deadline"







    # Set USB device power management for gaming peripherals



    ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="on"



  '';



};







hardware.uinput.enable = true;







# --- Performance & Core Services ---



powerManagement = {



  enable = false;



  cpuFreqGovernor = "performance";



};







services.thermald.enable = false;



services.lact.enable = true;







zramSwap.enable = lib.mkForce false;







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







# --- Display Manager & Desktop ---



services.displayManager.sddm = {



  enable = true;



  wayland.enable = true;



};







services.desktopManager.plasma6 = {



  enable = true;



  enableQt5Integration = true;



};







# Remove unused KDE packages



environment.plasma6.excludePackages = with pkgs.kdePackages; [



  elisa



  khelpcenter



];







services.flatpak.enable = true;



services.printing.enable = true;



services.fwupd.enable = true;







# --- Audio (Low-Latency Pipewire) ---



security.rtkit.enable = true;







services.pipewire = {



  enable = true;



  alsa.enable = true;



  alsa.support32Bit = true;



  pulse.enable = true;







  # Low-latency configuration for sim racing



  extraConfig.pipewire = {



    "10-rt-prio" = {



      "context.modules" = [



        {



          name = "libpipewire-module-rt";



          args = {



            "nice.level" = -11;



            "rt.prio" = 88;



          };



          flags = [ "ifexists" "nofail" ];



        }



      ];



    };



  };



};







# --- Networking & Localization ---



networking = {



  hostName = "nixos";



  networkmanager = {



    enable = true;



    wifi.powersave = false;



  };



  nameservers = [ "1.1.1.1" "8.8.8.8" ];



};







time.timeZone = "America/New_York";



i18n.defaultLocale = "en_US.UTF-8";







# --- User Configuration ---



users.users.radean = {



  isNormalUser = true;



  extraGroups = [ "networkmanager" "wheel" "video" "input" "realtime" "gamemode" ];



};







# Realtime scheduling for gaming/sim racing



security.pam.loginLimits = [



  { domain = "@realtime"; type = "-"; item = "rtprio"; value = 99; }



  { domain = "@realtime"; type = "-"; item = "memlock"; value = "unlimited"; }



  { domain = "@realtime"; type = "-"; item = "nice"; value = -20; }



];







users.groups.realtime = {};







nixpkgs.config.allowUnfree = true;







# --- System Packages ---



environment.systemPackages = with pkgs; [



  # Web Browsers



  google-chrome







  # Gaming & Windows Compatibility



  lutris



  bottles



  protonup-qt



  mangohud



  goverlay



  vulkan-tools







  # System & Monitoring



  nvtopPackages.full



  btop



  htop



  intel-gpu-tools



  sbctl







  # Performance tools



  linuxPackages.cpupower



  msr-tools







  # Notifications



  libnotify



];







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



      nv_powermizer_mode = 1;  # Prefer maximum performance



    };



    custom = {



      start = "${pkgs.libnotify}/bin/notify-send 'GameMode Activated' 'Performance optimizations enabled'";



      end = "${pkgs.libnotify}/bin/notify-send 'GameMode Deactivated' 'Normal performance restored'";



    };



  };



};







# --- Storage Optimizations ---



# Root filesystem optimization (ext4)



fileSystems."/" = {



  device = "/dev/disk/by-uuid/fe2e5d9a-1096-493a-9e10-57522c6168df";



  fsType = "ext4";



  options = [



    "noatime"



    "nodiratime"



  ];



};







# Secondary drive (btrfs)



fileSystems."/run/media/radean" = {



  device = "/dev/disk/by-uuid/de66f12c-d787-485d-a207-3590e64045ae";



  fsType = "btrfs";



  options = [



    "defaults"



    "compress=zstd:1"



    "noatime"



    "nodiratime"



    "space_cache=v2"



    "ssd"



    "discard=async"



    "autodefrag"



    "nofail"



  ];



};







system.stateVersion = "26.05";



}
