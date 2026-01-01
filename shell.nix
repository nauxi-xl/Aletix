{ pkgs, ... }:

let
in
pkgs.mkShell {
  name = "aletix-dev";
  nativeBuildInputs = with pkgs; [
    # Nix LSP for Vscode
    nixd
    nixfmt-rfc-style
    # Starlark LSP for Vscode
    starpls

    bazel_8
    bazel-buildtools
    buildifier

    bash
    python3
    clang-tools

    qemu
  ];

  shellHook = '''';
}
