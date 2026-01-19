{ config, pkgs, lib, ... }: {
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
}
