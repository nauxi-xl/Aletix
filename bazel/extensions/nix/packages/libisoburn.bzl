""""""

load("@rules_nixpkgs_core//:nixpkgs.bzl", "nixpkgs_package")

def package_libisoburn():
    nixpkgs_package(
        name = "libisoburn",
        attribute_path = "libisoburn",
        repository = "@nixpkgs",
        build_file_content = """
exports_files(glob(["**"]), visibility = ["//visibility:public"])
        """,
    )
