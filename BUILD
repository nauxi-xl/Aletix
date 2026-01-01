load("@aspect_bazel_lib//lib:write_source_files.bzl", "write_source_file")
load("@hedron_compile_commands//:refresh_compile_commands.bzl", "refresh_compile_commands")

refresh_compile_commands(
    name = "refresh_compile_commands",
    targets = {
        "//arch/x86:x86_deps": "",
    },
)

# For x86_64-elf toolchain
platform(
    name = "x86_64",
    constraint_values = [
        "@platforms//os:none",
        "@platforms//cpu:x86_64",
    ],
    visibility = ["//visibility:public"],
)

# For aarch64-none-elf toolchain
platform(
    name = "aarch64",
    constraint_values = [
        "@platforms//os:none",
        "@platforms//cpu:aarch64",
    ],
    visibility = ["//visibility:public"],
)

# For x86_64-w64-mingw32 toolchain
platform(
    name = "windows",
    constraint_values = [
        "@platforms//os:windows",
        "@platforms//cpu:x86_64",
    ],
    visibility = ["//visibility:public"],
)

genrule(
    name = "limine_geniso",
    srcs = [
        "//arch/x86/boot:real_entry",
        "//scripts:limine.conf",
        "@limine//:BOOTX64.EFI",
        "@limine//:limine-bios-cd.bin",
        "@limine//:limine-uefi-cd.bin",
        "@limine//:limine-bios.sys",
    ],
    outs = [
        "aletix.iso",
    ],
    cmd = """
    ISO_DIR=$$(mktemp -d)

    $(location @coreutils//:bin/mkdir) -p $$ISO_DIR/{boot/limine,EFI/BOOT}
    $(location @coreutils//:bin/cp) \
            $(location //arch/x86/boot:real_entry) \
            $$ISO_DIR/boot/
    $(location @coreutils//:bin/cp) \
            $(location //scripts:limine.conf) \
            $(location @limine//:limine-bios-cd.bin) \
            $(location @limine//:limine-uefi-cd.bin) \
            $(location @limine//:limine-bios.sys) \
            $$ISO_DIR/boot/limine/
    $(location @coreutils//:bin/cp) \
            $(location @limine//:BOOTX64.EFI) \
            $$ISO_DIR/EFI/BOOT/

    $(location @libisoburn//:bin/xorriso) -as mkisofs -R -r -J -b \
        boot/limine/limine-bios-cd.bin \
        -no-emul-boot -boot-load-size 4 -boot-info-table -hfsplus \
        -apm-block-size 2048 --efi-boot boot/limine/limine-uefi-cd.bin \
        -efi-boot-part --efi-boot-image --protective-msdos-label \
        $$ISO_DIR -o $@

    $(location @limine//:limine) bios-install $@
    """,
    tools = [
        "@coreutils//:bin/cp",
        "@coreutils//:bin/mkdir",
        "@libisoburn//:bin/xorriso",
        "@limine",
    ],
)

write_source_file(
    name = "geniso",
    in_file = ":limine_geniso",
    out_file = "aletix.iso",
)
