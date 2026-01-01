""""""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_cc//cc:defs.bzl", "CcInfo", "cc_common")

def _impl(ctx):
    _cc_toolchain = find_cpp_toolchain(ctx)
    compiler = _cc_toolchain.compiler_executable

    compilation_contexts = []
    for dep in ctx.attr.deps:
        if CcInfo in dep:
            compilation_contexts.append(dep[CcInfo].compilation_context)

    if compilation_contexts:
        compilation_context = cc_common.merge_compilation_contexts(
            compilation_contexts = compilation_contexts,
        )
    else:
        compilation_context = cc_common.create_compilation_context()

    objects = []

    # Only accept C/C++ or ASM files
    for src in ctx.files.srcs:
        ext = src.extension.lower()

        is_cpp = ext in ["cpp", "cc", "cxx", "c++", "mm"]
        is_c = ext in ["c", "s", "S", "asm"]

        if not (is_c or is_cpp):
            fail("File {} is not C/C++ or .[sS]/.asm file!".format(src.short_path))

        obj = ctx.actions.declare_file(src.basename[:-(len(src.extension) + 1)] +
                                       ".o" if src.extension else src.basename + ".o")

        flags = ctx.attr.copts[:]
        if is_c:
            flags += ctx.attr.conlyopts
        elif is_cpp:
            flags += ctx.attr.cxxopts

        flags += [
            "-I" + path
            for path in compilation_context.includes.to_list()
        ] + [
            "-iquote" + path
            for path in compilation_context.quote_includes.to_list()
        ] + [
            "-isystem" + path
            for path in compilation_context.system_includes.to_list()
        ]

        flags += [
            "-D" + define
            for define in compilation_context.defines.to_list()
        ] + [
            "-D" + define
            for define in compilation_context.local_defines.to_list()
        ]

        cmd = [
            "-c",
            src.path,
            "-o",
            obj.path,
        ] + flags

        inputs = depset(
            [src],
            transitive = [compilation_context.headers],
        ).to_list()

        ctx.actions.run(
            executable = compiler,
            arguments = cmd,
            inputs = inputs,
            outputs = [obj],
            mnemonic = "CCompile" if is_c else "CppCompile",
            progress_message = "Compiling {} → {}".format(src.short_path, obj.short_path),
        )

        objects.append(obj)

    return [
        DefaultInfo(files = depset(objects)),
        OutputGroupInfo(objects = depset(objects)),
    ]

cc_object = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "List of files to be compiled into C objects",
        ),
        "copts": attr.string_list(
            doc = "Options to pass to compiler when compile C/C++ objects",
        ),
        "cxxopts": attr.string_list(
            doc = "Options to pass to compiler when compile C++ objects",
        ),
        "conlyopts": attr.string_list(
            doc = "Options to pass to compiler when compile C objects",
        ),
        "deps": attr.label_list(
            doc = "List of dependencies that object files need",
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["cpp"],
    doc = "Rules to compile C/ASM sources into object files with full control of flags",
)
