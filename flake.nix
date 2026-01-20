{
  description = "High-Performance NixOS Configuration (2026)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        inherit system;
      };

      modules = [
        ./configuration.nix
        lanzaboote.nixosModules.lanzaboote

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.radean = import ./home.nix;
          home-manager.backupFileExtension = "backup";
        }

        ({ config, pkgs, lib, ... }: {
          nix = {
            settings = {
              max-jobs = "auto";
              cores = 0;
              auto-optimise-store = true;
              builders-use-substitutes = true;

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
              ];

              trusted-public-keys = [
                "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
              ];

              min-free = 5368709120;
              max-free = 10737418240;
              eval-cache = true;
            };

            extraOptions = ''
              keep-outputs = true
              keep-derivations = true
              experimental-features = nix-command flakes
              warn-dirty = false
              connect-timeout = 10
              fallback = true
            '';

            gc = {
              automatic = true;
              dates = "weekly";
              options = "--delete-older-than 7d";
            };

            optimise = {
              automatic = true;
              dates = [ "weekly" ];
            };

            channel.enable = false;
          };

          services.fwupd.enable = true;

          documentation = {
            enable = true;
            doc.enable = false;
            man.enable = true;
            dev.enable = false;
            nixos.enable = false;
          };
        })
      ];
    };

    nixosConfigurations."nixos-iso" = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = {
        inherit inputs;
        inherit system;
      };

      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        lanzaboote.nixosModules.lanzaboote
        ./iso-configuration.nix
      ];
    };
  };
}
