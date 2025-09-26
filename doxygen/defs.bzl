"""# rules_doxygen

Bazel rules for generating code documentation with [Doxygen](https://www.doxygen.nl/index.html).

## Setup

### MODULE.bazel

```python
http_archive = use_repo_rule("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_doxygen",
    # ...
    # ...
    # See releases page
)

register_toolchains(
    "@rules_doxygen//doxygen/toolchain",
)
```

## Rules

- [doxygen](#doxygen)
- [doxygen_runner](#doxygen_runner)
- [doxygen_toolchain](#doxygen_toolchain)

---
---
"""

load(
    "//doxygen/private:doxygen.bzl",
    _doxygen = "doxygen",
    _doxygen_runner = "doxygen_runner",
    _doxygen_toolchain = "doxygen_toolchain",
)

doxygen = _doxygen
doxygen_toolchain = _doxygen_toolchain
doxygen_runner = _doxygen_runner
