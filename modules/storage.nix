{ config, pkgs, lib, ... }: {
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
}
