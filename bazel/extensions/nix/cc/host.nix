let
  pkgs = import <nixpkgs> { };
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
  name = "host_nixpkgs_cc";
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
