load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

def repo_limine():
    git_repository(
        name = "limine",
        remote = "https://codeberg.org/Limine/Limine.git",
        commit = "1da714b5a801213cc13065bb5f514be82f2e051e",
        build_file_content = """
package(default_visibility = [ "//visibility:public" ])
load("@rules_cc//cc:defs.bzl", "cc_binary", "cc_library")

cc_library(
    name = "limine_include",
    hdrs = ["limine-bios-hdd.h"],
    visibility = [":__pkg__"]
)

cc_binary(
    name = "limine",
    srcs = [ "limine.c" ],
    deps = [ ":limine_include" ],
    copts = [ "-g", "-O2", "-pipe" ],
    conlyopts = [ "-std=c99" ],
    visibility = [ "//visibility:public" ]
)

exports_files([
    "BOOTAA64.EFI",
    "BOOTIA32.EFI",
    "BOOTLOONGARCH64.EFI",
    "BOOTRISCV64.EFI",
    "BOOTX64.EFI",
    "limine-bios-cd.bin",
    "limine-bios-pxe.bin",
    "limine-bios.sys",
    "limine-uefi-cd.bin",
])
        """,
    )
