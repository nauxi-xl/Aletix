""""""

load(
    "//bazel/extensions/nix:cc_toolchains.bzl",
    _impl_nixpkgs_cc_toolchains = "impl_nixpkgs_cc_toolchains",
)
load(
    "//bazel/extensions/nix:packages.bzl",
    _impl_nix_packages = "impl_nix_packages",
)

nix_packages = module_extension(
    implementation = _impl_nix_packages,
)

nixpkgs_cc_toolchains = module_extension(
    implementation = _impl_nixpkgs_cc_toolchains,
)
