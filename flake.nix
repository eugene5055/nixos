{
  description = "GLF-OS ISO Configuration - Optimized 2026";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    glf-channels.url = "git+https://framagit.org/gaming-linux-fr/glf-os/channels-glfos/testing-channels.git?ref=main";
    glf.url = "git+https://framagit.org/gaming-linux-fr/glf-os/glf-os.git?ref=testing";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, glf, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          {
            nixpkgs.config.allowUnfree = true;
            _module.args.pkgs-unstable = import nixpkgs {
              inherit system;
              config.allowUnfree = true;
            };
          }
          ./configuration.nix
          inputs.glf.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          {
            nix.settings = {
              experimental-features = [ "nix-command" "flakes" ];
              auto-optimise-store = true;
              trusted-users = [ "root" "@wheel" ];
            };
          }
        ];
      };
    };
}
