""""""

load("@rules_nixpkgs_core//:nixpkgs.bzl", "nixpkgs_package")

def package_gnuefi():
    nixpkgs_package(
        name = "gnu-efi",
        attribute_path = "gnu-efi",
        repository = "@nixpkgs",
        build_file_content = """
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "include",
    hdrs = glob(["include/**/*.h"]),
    includes = [
        "include",
        "include/efi/x86_64",
        "include/efi/protocol"
    ],
    visibility = [ "//visibility:public" ],
)

exports_files([
    "lib/crt0-x86_64-efi.o",
    "lib/elf_x86_64_efi.lds",
    "lib/libgnuefi.a",
    "lib/libefi.a"
],
    visibility = ["//visibility:public"]
)
        """,
    )
