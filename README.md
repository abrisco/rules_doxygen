<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_doxygen

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


<a id="doxygen"></a>

## doxygen

<pre>
doxygen(<a href="#doxygen-name">name</a>, <a href="#doxygen-config">config</a>, <a href="#doxygen-data">data</a>, <a href="#doxygen-output">output</a>, <a href="#doxygen-project_name">project_name</a>, <a href="#doxygen-target">target</a>)
</pre>

Generate documentation for C/C++ targets using doxygen.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="doxygen-config"></a>config |  The doxygen config file.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | //doxygen:config |
| <a id="doxygen-data"></a>data |  Additional source files to add to the Doxygen action.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="doxygen-output"></a>output |  The type of output to produce.   | String | optional | "html" |
| <a id="doxygen-project_name"></a>project_name |  An optional project name to use. If unset, the label name of <code>target</code> will be used.   | String | optional | "" |
| <a id="doxygen-target"></a>target |  The C/C++ target to generate documentation for   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="doxygen_toolchain"></a>

## doxygen_toolchain

<pre>
doxygen_toolchain(<a href="#doxygen_toolchain-name">name</a>, <a href="#doxygen_toolchain-doxygen">doxygen</a>)
</pre>

A toolchain used to power doxygen rules.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="doxygen_toolchain-doxygen"></a>doxygen |  The doxygen binary.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


