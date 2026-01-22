{
  config,
  pkgs,
  lib,
  ...
}:
{
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

    # Moza/Sim-Racing & Storage Optimizations
    extraRules = ''
      # NVMe Performance: Use 'none' scheduler for ultra-fast drives
      ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"

      # Peripheral Stability: Disable USB power-save for racing gear
      ACTION=="add", SUBSYSTEM=="usb", ATTR{power/control}="on"

      # Boxflat devices
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="1eaf", MODE="0666", TAG+="uaccess"
      KERNEL=="hidraw*", ATTRS{idVendor}=="346e", MODE="0666", TAG+="uaccess"
    '';
  };

  hardware.uinput.enable = true;
}
