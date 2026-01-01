load("//bazel/rules:defs.bzl", "cc_link", "cc_object")

cc_object(
    name = "limine_entry",
    srcs = [
        "limine_main.c",
    ],
    copts = [
        "-g",
        "-O2",
        "-pipe",
        "-std=gnu11",
        "-Wall",
        "-Wextra",
        "-fno-stack-protector",
        "-fno-stack-check",
        "-fno-lto",
        "-fno-PIC",
        "-ffunction-sections",
        "-fdata-sections",
        "-m64",
        "-march=x86-64",
        "-mabi=sysv",
        "-mno-80387",
        "-mno-mmx",
        "-mno-sse",
        "-mno-sse2",
        "-mno-red-zone",
        "-nostdlib",
        "-mcmodel=kernel",
    ],
    visibility = [
        "//arch/x86:__pkg__",
    ],
    deps = [
        "//arch/x86:arch_x86_include",
        "//include",
    ],
)

cc_link(
    name = "real_entry",
    srcs = [
        ":limine_entry",
    ],
    out = "real_entry",
    additional_linker_inputs = [
        "linker.ld",
    ],
    linkopts = [
        "-Wl,-m,elf_x86_64",
        "-nostdlib",
        "-Wl,-z,max-page-size=0x1000",
        "-Wl,--gc-sections",
    ],
    visibility = ["//visibility:public"],
    deps = [
        "//arch/x86:arch_x86_include",
        "//include",
    ],
)
