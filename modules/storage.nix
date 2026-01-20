{ config, pkgs, lib, ... }: {
  # --- Storage Optimizations ---
  # Root filesystem optimization (ext4)
  fileSystems."/".options = [
    "noatime"
    "nodiratime"
  ];

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
