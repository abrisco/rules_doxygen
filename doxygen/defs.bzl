"""# rules_doxygen

Bazel rules for generating code documentation with [Doxygen](https://www.doxygen.nl/index.html).

## Setup

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# See releases for urls and checksums
http_archive(
    name = "rules_doxygen",
    sha256 = "{sha256}",
    urls = ["https://github.com/abrisco/rules_doxygen/releases/download/{version}/rules_doxygen-v{version}.tar.gz"],
)

load("@rules_doxygen//doxygen:repositories.bzl", "rules_doxygen_dependencies", "doxygen_register_toolchains")

rules_doxygen_dependencies()

doxygen_register_toolchains()
```

## Rules

- [doxygen](#doxygen)
- [doxygen_toolchain](#doxygen_toolchain)

---
---
"""

load(
    "//doxygen/private:doxygen.bzl",
    _doxygen = "doxygen",
    _doxygen_toolchain = "doxygen_toolchain",
)

doxygen = _doxygen
doxygen_toolchain = _doxygen_toolchain
