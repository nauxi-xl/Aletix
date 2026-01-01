""""""

load("@rules_nixpkgs_cc//:cc.bzl", "nixpkgs_cc_configure")

def impl_nixpkgs_cc_toolchains(_module_ctx):
    nixpkgs_cc_configure(
        name = "host_config_cc",
        nix_file = "//bazel/extensions/nix/cc:host.nix",
        repository = "@nixpkgs",
        register = False,
    )

    nixpkgs_cc_configure(
        name = "x86_64-w64-mingw32_config_cc",
        attribute_path = "pkgsCross.mingwW64.buildPackages.gcc",
        repository = "@nixpkgs",
        exec_constraints = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_constraints = [
            "@platforms//os:windows",
            "@platforms//cpu:x86_64",
        ],
        cross_cpu = "k8",
        cc_lang = "c",
        cc_std = "c23",
        register = False,
    )

    nixpkgs_cc_configure(
        name = "x86_64-elf_config_cc",
        nix_file = "//bazel/extensions/nix/cc:x86_64-elf.nix",
        repository = "@nixpkgs",
        exec_constraints = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_constraints = [
            "@platforms//os:none",
            "@platforms//cpu:x86_64",
        ],
        cross_cpu = "k8",
        register = False,
    )

    nixpkgs_cc_configure(
        name = "aarch64-none-elf_config_cc",
        attribute_path = "pkgsCross.aarch64-embedded.buildPackages.gcc",
        repository = "@nixpkgs",
        exec_constraints = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ],
        target_constraints = [
            "@platforms//os:none",
            "@platforms//cpu:aarch64",
        ],
        cross_cpu = "aarch64",
        register = False,
    )
