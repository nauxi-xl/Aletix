""""""

def _impl_external_archives(_module_ctx):
    pass

external_archives = module_extension(
    implementation = _impl_external_archives,
)
