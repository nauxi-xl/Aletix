""" Limine utility """

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def archive_limine():
    """
    Unused
    """
    http_archive(
        name = "limine",
        url = "https://codeberg.org/Limine/Limine/releases/download/v10.6.0/limine-10.6.0.tar.gz",
        strip_prefix = "limine-10.6.0",
    )
