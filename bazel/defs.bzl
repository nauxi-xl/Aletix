""""""

# Turn off all rules_cc's features
# because it may cause undefined
# compile behaviours
NO_CC_FEATURES = [
    "-opt",
    "-dbg",
    "-fastbuild",
    "-static_linking_mode",
    "-dynamic_linking_mode",
    "-static_link_cpp_runtimes",
    "-default_compile_flags",
    "-default_link_flags",
    "-pic",
    "-pie",
    "-hardening",
    "-linker_gc_sections",
    "-fdo_instrument",
    "-fdo_optimize",
    "-cs_fdo_instrument",
    "-cs_fdo_optimize",
    "-fdo_prefetch_hints",
    "-autofdo",
    "-per_object_debug_info",
    "-fully_static_link",
    "-strip_debug_symbol",
    "-gsplit_dwarf",
    "-coverage",
    "-llvm_coverage_map_format",
    "-gcc_coverage_map_format",
    "-legacy_link_flag",
    "-legacy_compile_flag",
    "all_builtin_features",
]
