""""""

load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain")
load("@rules_cc//cc:defs.bzl", "CcInfo", "cc_common")

def _impl(ctx):
    _cc_toolchain = find_cpp_toolchain(ctx)
    _compiler = _cc_toolchain.compiler_executable
    _linker = _cc_toolchain.compiler_executable

    out_name = ctx.attr.out or ctx.label.name
    if ctx.attr.linkshared:
        output_file = ctx.actions.declare_file(out_name + ".so")
    else:
        output_file = ctx.actions.declare_file(out_name)

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

    object_files = []
    static_libs = []
    sources_to_compile = []

    for src in ctx.files.srcs:
        if src.extension in ["o"]:
            object_files.append(src)
        elif src.extension in ["a"]:
            static_libs.append(src)
        elif src.extension in ["c", "cc", "cpp", "cxx", "C", "s", "S", "asm"]:
            sources_to_compile.append(src)
        else:
            fail("Unsupported file in srcs: {}".format(src.basename))

    for dep in ctx.attr.deps:
        if DefaultInfo in dep:
            for file in dep[DefaultInfo].files.to_list():
                if file.extension in ["o"]:
                    object_files.append(file)
                elif file.extension in ["a"]:
                    static_libs.append(file)

        if OutputGroupInfo in dep and hasattr(dep[OutputGroupInfo], "object"):
            for file in dep[OutputGroupInfo].objects.to_list():
                if file.extension == "o":
                    object_files.append(file)

    for src in sources_to_compile:
        ext = src.extension.lower()
        is_cpp = ext in ["cpp", "cc", "cxx", "c++"]

        # Output .o
        obj_name = src.basename.rsplit(".", 1)[0] + ".o"
        obj = ctx.actions.declare_file(obj_name)

        # Flags cho compile
        compile_flags = ctx.attr.copts[:]
        if is_cpp:
            compile_flags += ctx.attr.cxxopts
        compile_flags += ctx.attr.conlyopts

        compile_flags += [
            "-I" + path
            for path in compilation_context.includes.to_list()
        ] + [
            "-iquote" + path
            for path in compilation_context.quote_includes.to_list()
        ] + [
            "-isystem" + path
            for path in compilation_context.system_includes.to_list()
        ]

        compile_flags += [
            "-D" + define
            for define in compilation_context.defines.to_list()
        ] + [
            "-D" + define
            for define in compilation_context.local_defines.to_list()
        ]

        cmd = [
            _compiler,
            "-c",
            src.path,
            "-o",
            obj.path,
        ] + compile_flags

        ctx.actions.run(
            executable = _compiler,
            arguments = cmd,
            inputs = [src],
            outputs = [obj],
            mnemonic = "CCompile" if not is_cpp else "CppCompile",
            progress_message = "Compiling {} → {}".format(src.short_path, obj.short_path),
        )

        object_files.append(obj)

    link_cmd = []
    link_cmd += ctx.attr.linkopts

    additional_inputs = []
    for target in ctx.attr.additional_linker_inputs:
        if DefaultInfo in target:
            additional_inputs += target[DefaultInfo].files.to_list()

    for input_file in additional_inputs:
        ext = input_file.extension.lower()
        basename = input_file.basename.lower()

        if ext in ["ld", "lds", "linker"] or "linker" in basename:
            link_cmd.append("-Wl,-T,{}".format(input_file.path))
        elif ext in ["ver", "version"]:
            link_cmd.append("-Wl,--version-script=" + input_file.path)
        elif ext == "def":
            link_cmd.append("-Wl,--def=" + input_file.path)
        elif ext == "map":
            link_cmd.append("-Wl,-Map=" + input_file.path)
        else:
            link_cmd.append(input_file.path)

    if ctx.attr.linkstatic and not ctx.attr.linkshared:
        link_cmd.append("-static")

    if ctx.attr.linkshared:
        link_cmd.append("-shared")

    link_cmd += ["-o", output_file.path]
    link_cmd += [obj.path for obj in object_files]

    for lib in static_libs:
        link_cmd += ["-Wl,--whole-archive", lib.path, "-Wl,--no-whole-archive"]

    link_inputs = (
        object_files +
        static_libs +
        ctx.files.additional_linker_inputs
    )

    # Run link action
    ctx.actions.run(
        executable = _linker,
        arguments = link_cmd,
        inputs = link_inputs,
        outputs = [output_file],
        mnemonic = "LdLink",
        progress_message = "Linking {} → {}".format(", ".join([f.basename for f in object_files + static_libs]), output_file.short_path),
    )

    return [
        DefaultInfo(
            files = depset([output_file]),
            executable = output_file if not ctx.attr.linkshared else None,
        ),
    ]

cc_link = rule(
    implementation = _impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
            doc = "List of files to be compiled into objects",
        ),
        "out": attr.string(
            doc = "Final file name, default to label name",
        ),
        "copts": attr.string_list(
            doc = "Options to pass to C compiler when compile objects",
        ),
        "cxxopts": attr.string_list(
            doc = "Options to pass to C++ compiler when compile objects",
        ),
        "conlyopts": attr.string_list(
            doc = "Options to pass to C/C++ compiler when compile objects",
        ),
        "linkopts": attr.string_list(
            doc = "Options to pass to compiler when linking",
        ),
        "additional_linker_inputs": attr.label_list(
            allow_files = True,
            doc = "List of files that are needed when linking",
        ),
        "linkstatic": attr.bool(
            default = True,
            doc = "Enable static linking mode, will generate a file name [out]",
        ),
        "linkshared": attr.bool(
            default = False,
            doc = "Enable dynamic linking mode, will generate a file name [out].so",
        ),
        "deps": attr.label_list(
            doc = "List of dependencies that are needed when linking",
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["cpp"],
    doc = "Rules linking C/C++/ASM sources into final files with full control of flags",
)
