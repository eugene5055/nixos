{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
{
  # --- Boot & Kernel (Maximum Performance) ---
  boot = {
    kernelPackages = lib.mkForce pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;

    # Aggressive performance kernel parameters
    kernelParams = [
      # CPU Performance
      "intel_pstate=active"
      "processor.max_cstate=1"
      "preempt=full"
      "transparent_hugepage=always"

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
      "nvidia-drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"

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
      "vm.nr_hugepages" = lib.mkForce 2048; # 2GB of huge pages

      # File system performance
      "fs.file-max" = lib.mkForce 2097152;
      "fs.inotify.max_user_watches" = lib.mkForce 524288;

      # Scheduler performance
      "kernel.sched_migration_cost_ns" = lib.mkForce 5000000;
      "kernel.sched_autogroup_enabled" = lib.mkForce 0;
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

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
}
