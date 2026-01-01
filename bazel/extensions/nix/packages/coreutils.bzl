""""""

load("@rules_nixpkgs_core//:nixpkgs.bzl", "nixpkgs_package")

def package_coreutils():
    nixpkgs_package(
        name = "coreutils",
        attribute_path = "coreutils",
        repository = "@nixpkgs",
        build_file_content = """
exports_files(glob(["**"]), visibility = ["//visibility:public"])
        """,
    )
