load("@aspect_bazel_lib//lib:transitions.bzl", "platform_transition_filegroup")
load("@rules_cc//cc:defs.bzl", "cc_library")

cc_library(
    name = "arch_x86_include",
    hdrs = [
        "include/limine.h",
    ],
    includes = ["include"],
    visibility = [":__subpackages__"],
)

platform_transition_filegroup(
    name = "x86_deps",
    srcs = [
        "//arch/x86/boot:limine_",
        "//arch/x86/boot:limine_entry",
    ],
    target_platform = "//:x86_64",
)
