{
  description = "GLF-OS ISO Configuration - Optimized 2026";


  inputs = {
    glf-channels.url = "git+https://framagit.org/gaming-linux-fr/glf-os/channels-glfos/testing-channels.git?ref=main";
    nixpkgs.follows = "nixpkgs-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    glf.url = "git+https://framagit.org/gaming-linux-fr/glf-os/glf-os.git?ref=testing";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, glf, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # Modern 2026 Formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system;

        # Use a function for specialArgs to allow lazy evaluation of pkgs-unstable
        specialArgs = {
          inherit inputs;
          pkgs-unstable = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
        };

        modules = [
          ./configuration.nix
          inputs.glf.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote

          # Consolidated System Settings Module
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              # 2026 Optimization: Auto-detects and uses binary caches for GLF-OS
              auto-optimise-store = true;
            };
          }
        ];
      };
    };
}
