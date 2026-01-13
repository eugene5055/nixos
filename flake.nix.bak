{
  description = "GLF-OS ISO Configuration - Optimized 2026";

  inputs = {
    glf-channels.url = "git+https://framagit.org/gaming-linux-fr/glf-os/channels-glfos/glf-os-channels.git?ref=main";
    nixpkgs.follows = "glf-channels/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    glf.url = "git+https://framagit.org/gaming-linux-fr/glf-os/glf-os.git?ref=main";

    lanzaboote = {
      # Updated to current 2026 stable release or main for Blackwell (RTX 5090) support
      url = "github:nix-community/lanzaboote/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      glf,
      lanzaboote,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # Unstable provider for cutting-edge gaming tools
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # Standard 2026 Formatter:
      # 'nixfmt-rfc-style' is now aliased to 'nixfmt'.
      # 'nixfmt-tree' is recommended to avoid recursion warnings.
      formatter.${system} = pkgs.nixfmt-tree;

      nixosConfigurations."GLF-OS" = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          glf.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          {
            nixpkgs.config.allowUnfree = true;
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];
          }
        ];

        specialArgs = {
          inherit inputs pkgs-unstable;
        };
      };
    };
}
