<!-- Generated with Stardoc: http://skydoc.bazel.build -->

# rules_doxygen

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

<a id="doxygen"></a>

## doxygen

<pre>
load("@rules_doxygen//doxygen:defs.bzl", "doxygen")

doxygen(<a href="#doxygen-name">name</a>, <a href="#doxygen-data">data</a>, <a href="#doxygen-config">config</a>, <a href="#doxygen-output">output</a>, <a href="#doxygen-project_name">project_name</a>, <a href="#doxygen-target">target</a>)
</pre>

Generate documentation for C/C++ targets using doxygen.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="doxygen-data"></a>data |  Additional source files to add to the Doxygen action.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="doxygen-config"></a>config |  The doxygen config file.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//doxygen:config"`  |
| <a id="doxygen-output"></a>output |  The type of output to produce.   | String | optional |  `"html"`  |
| <a id="doxygen-project_name"></a>project_name |  An optional project name to use. If unset, the label name of `target` will be used.   | String | optional |  `""`  |
| <a id="doxygen-target"></a>target |  The C/C++ target to generate documentation for   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="doxygen_runner"></a>

## doxygen_runner

<pre>
load("@rules_doxygen//doxygen:defs.bzl", "doxygen_runner")

doxygen_runner(<a href="#doxygen_runner-name">name</a>, <a href="#doxygen_runner-config">config</a>)
</pre>

A rule defining a doxygen exectuable that runs on a config from the root of the current workspace.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen_runner-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="doxygen_runner-config"></a>config |  The doxygen config file.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `"@rules_doxygen//doxygen:config"`  |


<a id="doxygen_toolchain"></a>

## doxygen_toolchain

<pre>
load("@rules_doxygen//doxygen:defs.bzl", "doxygen_toolchain")

doxygen_toolchain(<a href="#doxygen_toolchain-name">name</a>, <a href="#doxygen_toolchain-doxygen">doxygen</a>)
</pre>

A toolchain used to power doxygen rules.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="doxygen_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="doxygen_toolchain-doxygen"></a>doxygen |  The doxygen binary.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


