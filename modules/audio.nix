{
  config,
  pkgs,
  lib,
  ...
}:
{
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
            flags = [
              "ifexists"
              "nofail"
            ];
          }
        ];
      };
    };
  };
}
