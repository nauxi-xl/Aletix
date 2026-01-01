""""""

load("@rules_nixpkgs_core//:nixpkgs.bzl", "nixpkgs_package")

def package_gnumake():
    nixpkgs_package(
        name = "gnumake",
        attribute_path = "gnumake",
        repository = "@nixpkgs",
        build_file_content = """
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "include",
    hdrs = glob(["include/**/*.h"]),
    includes = [
        "include",
    ],
    visibility = [ "//visibility:public" ],
)

exports_files([
    "bin/make"
],
    visibility = ["//visibility:public"]
)
        """,
    )
