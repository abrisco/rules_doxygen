"""rules_doxygen dependencies"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//tools/homebrew:brew.bzl", "homebrew_bottle")

def rules_doxygen_dependencies():
    maybe(
        http_archive,
        name = "rules_cc",
        urls = ["https://github.com/bazelbuild/rules_cc/releases/download/0.0.9/rules_cc-0.0.9.tar.gz"],
        sha256 = "2037875b9a4456dce4a79d112a8ae885bbc4aad968e6587dca6e64f3a0900cdf",
        strip_prefix = "rules_cc-0.0.9",
    )

# buildifier: disable=unnamed-macro
def doxygen_register_toolchains(register_toolchains = True):
    """Define external repositories for doxygen and register doxygen toolchains.

    Args:
        register_toolchains (bool, optional): If `True`, the default toolchains will be registered.
    """

    maybe(
        http_archive,
        name = "doxygen_linux_amd64",
        urls = ["https://github.com/doxygen/doxygen/releases/download/Release_1_9_8/doxygen-1.9.8.linux.bin.tar.gz"],
        sha256 = "dda773bdc62384b7d796fe8b6c5029daad72483e4c8ad4abf6ee9fb98b649388",
        strip_prefix = "doxygen-1.9.8",
        build_file = Label("//3rdparty/doxygen:BUILD.doxygen_linux.bazel"),
    )

    maybe(
        http_archive,
        name = "doxygen_windows_amd64",
        urls = ["https://github.com/doxygen/doxygen/releases/download/Release_1_9_8/doxygen-1.9.8.windows.x64.bin.zip"],
        sha256 = "03f98f585acee18df0575262feffccc8a93a5aeacd4ee8c21872aeef12532244",
        build_file = Label("//3rdparty/doxygen:BUILD.doxygen_windows.bazel"),
    )

    maybe(
        homebrew_bottle,
        name = "doxygen_macos_arm64",
        urls = ["https://ghcr.io/v2/homebrew/core/doxygen/blobs/sha256:7699071865959f0d7a6dca86a21bd302a4a628e083f167214adfaa805b32b95c"],
        sha256 = "7699071865959f0d7a6dca86a21bd302a4a628e083f167214adfaa805b32b95c",
        strip_prefix = "doxygen/1.9.8",
        build_file = Label("//3rdparty/doxygen:BUILD.doxygen_macos.bazel"),
    )

    if register_toolchains:
        native.register_toolchains(str(Label("//doxygen/private/toolchains:doxygen_toolchain")))
