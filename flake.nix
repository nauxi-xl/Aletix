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

        targetPlatforms = {
          i386 = {
            cross = "i686";
            triple = "i686-elf";
          };
          x86_64 = {
            cross = "x86_64";
            triple = "x86_64-elf";
          };
          arm = {
            cross = "arm";
            triple = "arm-none-eabi";
          };
          aarch64 = {
            cross = "aarch64";
            triple = "aarch64-elf";
          };
          riscv32 = {
            cross = "riscv32";
            triple = "riscv32-elf";
          };
          riscv64 = {
            cross = "riscv64";
            triple = "riscv64-elf";
          };
        };
        targetOf = platform: targetPlatforms.${platform} or (throw "Unknown target platform: ${platform}");

        nativePackages =
          targetPlatform:
          let
            target = targetOf targetPlatform;
          in
          with pkgs;
          [
            # Utilities
            git
            qemu_full
            texliveFull

            # Tools
            ccache
            gnumake
            flex
            bison
            pkg-config-unwrapped
            pahole
            perl
            python3
            sparse

            # Compression tools
            gzip
            bzip2
            lzop
            lz4
            xz
            zstd
            gnutar

            # LLVM
            llvmPackages_latest.llvm
            llvmPackages_latest.clang-unwrapped
            llvmPackages_latest.lld

            # Libs
            ncurses
          ]
          ++ (with buildPackages.pkgsCross."${target.cross}-embedded"; [
            gccWithoutTargetLibc
            binutils-unwrapped
            gdb
          ]);

        mkKernel =
          targetPlatform:
          pkgs.callPackage ./default.nix {
            inherit targetPlatform;
            nativePackages = nativePackages targetPlatform;
          };
        mkDevShell =
          targetPlatform:
          let
            target = targetOf targetPlatform;
          in
          pkgs.mkShell {
            nativeBuildInputs = nativePackages targetPlatform;

            shellHook = ''
              export ARCH=${targetPlatform}
              export CROSS_COMPILE=${target.triple}-

              echo "Welcome to the Aletix development shell for ${targetPlatform}!"
            '';
          };
      in
      {
        packages = rec {
          aletix-i386 = mkKernel "i386";
          aletix-x86_64 = mkKernel "x86_64";
          aletix-arm = mkKernel "arm";
          aletix-aarch64 = mkKernel "aarch64";
          aletix-riscv32 = mkKernel "riscv32";
          aletix-riscv64 = mkKernel "riscv64";
          aletix = aletix-x86_64;
          default = aletix;

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

        devShells = rec {
          i386 = mkDevShell "i386";
          x86_64 = mkDevShell "x86_64";
          arm = mkDevShell "arm";
          aarch64 = mkDevShell "aarch64";
          riscv32 = mkDevShell "riscv32";
          riscv64 = mkDevShell "riscv64";
          default = x86_64;
        };
      }
    );
}
