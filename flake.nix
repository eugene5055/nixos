{
  description = "GLF-OS ISO Configuration - Optimized 2026";

  inputs = {
    glf-channels.url = "git+framagit.org";
    nixpkgs.follows = "glf-channels/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "git+framagit.org";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
    in
    {
      # Use the 2026 official standard formatter
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system;
        # Passing 'inputs' is enough to access all dependencies in modules
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
          inputs.glf.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote

          # Inline module for global settings and unstable overlay
          {
            nixpkgs.config.allowUnfree = true;
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  inherit (final) system;
                  config.allowUnfree = true;
                };
              })
            ];
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }
        ];
      };
    };
}
