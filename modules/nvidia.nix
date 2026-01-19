{ config, pkgs, lib, ... }: {
  # --- NVIDIA Graphics (Maximum Performance) ---
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      libvdpau-va-gl
      nvidia-vaapi-driver
      libva-vdpau-driver
      vulkan-loader
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      libva
      libvdpau
      libvdpau-va-gl
      vulkan-loader
    ];
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    forceFullCompositionPipeline = false;
  };

  # NVIDIA performance environment variables
  environment.variables = {
    __GL_YIELD = "NOTHING";
    __GL_THREADED_OPTIMIZATION = "1";
    __GL_SYNC_TO_VBLANK = "0";
    __GL_SHADER_DISK_CACHE = "1";
    __GL_SHADER_DISK_CACHE_SKIP_CLEANUP = "1";
    __GL_MaxFramesAllowed = "1";
    KWIN_TRIPLE_BUFFER = "1";
    PROTON_ENABLE_NVAPI = "1";
  };
}
