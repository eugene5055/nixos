{
  config,
  pkgs,
  lib,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    builders-use-substitutes = true;
    warn-dirty = false;
    connect-timeout = 10;
    fallback = true;
    keep-outputs = true;
    keep-derivations = true;
    trusted-users = [
      "root"
      "@wheel"
    ];
    min-free = 5368709120;
    max-free = 10737418240;
    eval-cache = true;
    use-xdg-base-directories = true;
    system-features = [
      "nixos-test"
      "benchmark"
      "big-parallel"
      "kvm"
    ];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://cuda-maintainers.cachix.org"
      "https://attic.xuyh0120.win/lantian"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
      "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  nix.channel.enable = false;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (final: prev: {
      gamescope = prev.gamescope.overrideAttrs (old: {
        nativeBuildInputs =
          let
            cmakePolicyWrapper = prev.writeShellScriptBin "cmake" ''
              exec ${prev.cmake}/bin/cmake -DCMAKE_POLICY_VERSION_MINIMUM=3.5 "$@"
            '';
          in
          [
            cmakePolicyWrapper
            prev.glm
            prev.stb
          ]
          ++ (old.nativeBuildInputs or [ ]);
        version = "3.16.2";
        src = builtins.fetchGit {
          url = "https://github.com/ValveSoftware/gamescope.git";
          rev = "2ccfa53b619d43d7a08f2457474f471552b7e6fb";
          submodules = true;
        };
        # Disable nixpkgs patching for the pinned upstream revision.
        patches = [ ];
        # The upstream install script expects runtime paths that do not
        # exist in the Nix build sandbox; binaries are already installed.
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace meson.build \
              --replace-fail "meson.add_install_script('default_scripts_install.sh')" ""
          '';
        # Without nixpkgs system-libraries patching, allow subprojects to build.
        mesonInstallFlags = [ ];
        # 3.16.2 does not define these Meson options.
        mesonFlags =
          lib.filter
            (flag:
              !(lib.hasPrefix "-Dglm_include_dir=" flag || lib.hasPrefix "-Dstb_include_dir=" flag)
            )
            (old.mesonFlags or [ ]);
      });
    })
  ];
}
