{
  description = "GLF-OS ISO Configuration - Optimized 2026";


  inputs = {
    glf-channels.url = "git+https://framagit.org/gaming-linux-fr/glf-os/channels-glfos/glf-os-channels.git?ref=main";
    nixpkgs.follows = "glf-channels/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "git+https://framagit.org/gaming-linux-fr/glf-os/glf-os.git?ref=main";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, nixpkgs-unstable, ... }:
    let
      system = "x86_64-linux";
      # This block is MANDATORY for GLF-OS modules
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-rfc-style;

      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system;
        # You MUST inherit pkgs-unstable here so modules can see it
        specialArgs = { inherit inputs pkgs-unstable; };
        modules = [
          ./configuration.nix
          inputs.glf.nixosModules.default
          inputs.lanzaboote.nixosModules.lanzaboote
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [ "nix-command" "flakes" ];
          }
        ];
      };
    };
}
