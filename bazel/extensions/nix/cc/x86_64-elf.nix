let
  pkgs = (import <nixpkgs> { }).pkgsCross.x86_64-embedded.buildPackages;
in
let
  crossCC = pkgs.wrapCCWith {
    cc = pkgs.gcc-unwrapped;
    bintools = pkgs.wrapBintoolsWith {
      bintools = pkgs.binutils-unwrapped;
      libc = pkgs.glibc;
    };
    extraPackages = [ pkgs.glibc ];
  };
in
pkgs.buildEnv ({
  name = "x86_64-elf_nixpkgs_cc";
  paths = [
    crossCC
    crossCC.bintools
  ];
  pathsToLink = [ "/bin" ];
  passthru = {
    inherit (crossCC) isClang targetPrefix;
    originalName = crossCC.name;
  };
})
