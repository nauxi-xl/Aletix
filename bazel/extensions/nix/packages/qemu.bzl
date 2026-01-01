""""""

load("@rules_nixpkgs_core//:nixpkgs.bzl", "nixpkgs_package")

def package_qemu():
    nixpkgs_package(
        name = "qemu",
        attribute_path = "qemu_full",
        repository = "@nixpkgs",
        build_file_content = """
exports_files(glob(["**"]), visibility = ["//visibility:public"])
        """,
    )
