"""Bzlmod module extensions that are only used internally"""

load("@apple_support//tools/http_dmg:http_dmg.bzl", "http_dmg")
load("@bazel_features//:features.bzl", "bazel_features")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# TODO: https://github.com/bazelbuild/apple_support/pull/461
_MACOS_BUILD_CONTENT = """\
filegroup(
    name = "doxygen",
    srcs = ["Doxygen.app/Contents/Resources/doxygen"],
    data = glob(["Doxygen.app/**"]),
    visibility = ["//visibility:public"],
)
"""

# buildifier: disable=unnamed-macro
def _doxygen_register_toolchains():
    """Define external repositories for doxygen and register doxygen toolchains.

    Returns:
        A list of repository names instantiated for the toolchains.
    """
    linux_amd64 = "doxygen_linux_amd64"
    maybe(
        http_archive,
        name = linux_amd64,
        urls = ["https://github.com/doxygen/doxygen/releases/download/Release_1_14_0/doxygen-1.14.0.linux.bin.tar.gz"],
        integrity = "sha256-5dauJNC/PwzcTY8UZya4nKMjki8ZRBr5mxhy1QNmWtY=",
        strip_prefix = "doxygen-1.14.0",
        build_file = Label("//3rdparty/doxygen:BUILD.doxygen_linux.bazel"),
    )

    macos_amd64 = "doxygen_macos_amd64"
    maybe(
        http_dmg,
        name = macos_amd64,
        integrity = "sha256-rSxxyyhhANTqzNC52SdRyIxL0FAZkPfszFCqlG+Cfcc=",
        urls = ["https://github.com/doxygen/doxygen/releases/download/Release_1_14_0/Doxygen-1.14.0.dmg"],
        # build_file = Label("//3rdparty/doxygen:BUILD.doxygen_macos.bazel"),
        build_file_content = _MACOS_BUILD_CONTENT,
    )

    macos_arm64 = "doxygen_macos_arm64"
    maybe(
        http_dmg,
        name = macos_arm64,
        integrity = "sha256-rSxxyyhhANTqzNC52SdRyIxL0FAZkPfszFCqlG+Cfcc=",
        urls = ["https://github.com/doxygen/doxygen/releases/download/Release_1_14_0/Doxygen-1.14.0.dmg"],
        # build_file = Label("//3rdparty/doxygen:BUILD.doxygen_macos.bazel"),
        build_file_content = _MACOS_BUILD_CONTENT,
    )

    windows_amd64 = "doxygen_windows_amd64"
    maybe(
        http_archive,
        name = windows_amd64,
        urls = ["https://github.com/doxygen/doxygen/releases/download/Release_1_14_0/doxygen-1.14.0.windows.x64.bin.zip"],
        integrity = "sha256-OEN0LGBOFF2rJvdOvThq8GVrwv62+DTBLBq7ezwBnYs=",
        build_file = Label("//3rdparty/doxygen:BUILD.doxygen_windows.bazel"),
    )

    return [
        linux_amd64,
        macos_amd64,
        macos_arm64,
        windows_amd64,
    ]

def _internal_deps_impl(module_ctx):
    direct_deps = []

    direct_deps.extend(_doxygen_register_toolchains())

    # is_dev_dep is ignored here. It's not relevant for internal_deps, as dev
    # dependencies are only relevant for module extensions that can be used
    # by other MODULES.
    metadata_kwargs = {
        "root_module_direct_deps": [repo for repo in direct_deps],
        "root_module_direct_dev_deps": [],
    }

    if bazel_features.external_deps.extension_metadata_has_reproducible:
        metadata_kwargs["reproducible"] = True

    return module_ctx.extension_metadata(**metadata_kwargs)

# This is named a single character to reduce the size of path names when running build scripts, to reduce the chance
# of hitting the 260 character windows path name limit.
i = module_extension(
    doc = "Dependencies for rules_doxygen",
    implementation = _internal_deps_impl,
)
