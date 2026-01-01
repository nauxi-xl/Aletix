""""""

load("//bazel/extensions/nix/packages:coreutils.bzl", _package_coreutils = "package_coreutils")
load("//bazel/extensions/nix/packages:gnu-efi.bzl", _package_gnuefi = "package_gnuefi")
load("//bazel/extensions/nix/packages:gnumake.bzl", _package_gnumake = "package_gnumake")
load("//bazel/extensions/nix/packages:libisoburn.bzl", _package_libisoburn = "package_libisoburn")
load("//bazel/extensions/nix/packages:qemu.bzl", _package_qemu = "package_qemu")

def impl_nix_packages(_module_ctx):
    """
    A list of Nix packages to use when building/running Aletix

    Args:
        _module_ctx: Unused
    """
    _package_gnuefi()
    _package_gnumake()
    _package_libisoburn()
    _package_coreutils()
    _package_qemu()
