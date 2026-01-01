{
  description = "Aletix - A multi-architecture kernel for AletheiaOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nixos-wsl,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages = {

          # NixOS-WSL
          nixosConfigurations = {
            "nixos" = nixpkgs.lib.nixosSystem {
              inherit system;
              specialArgs = { inherit inputs; };
              modules = [
                ./scripts/nix/configuration.nix
                nixos-wsl.nixosModules.default
                {
                  system.stateVersion = "25.05";
                  wsl.enable = true;
                  wsl.defaultUser = "nixos";
                }
              ];
            };
          };
        };

        devShells = {
          default = pkgs.callPackage ./shell.nix { inherit pkgs; };
        };
      }
    );
}
