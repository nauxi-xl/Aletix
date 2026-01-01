""""""

load("//bazel/rules:cc_link.bzl", _cc_link = "cc_link")
load("//bazel/rules:cc_object.bzl", _cc_object = "cc_object")

cc_object = _cc_object
cc_link = _cc_link
