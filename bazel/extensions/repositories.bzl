""""""

load("//bazel/extensions/repos:limine.bzl", _repo_limine = "repo_limine")

def _impl_external_repos(_module_ctx):
    _repo_limine()

external_repos = module_extension(
    implementation = _impl_external_repos,
)
