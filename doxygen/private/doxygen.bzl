"""Bazel rules for running Doxygen"""

DoxygenInfo = provider(
    doc = "Information on doxygen outputs. Only one attribute is expected to be set at a time.",
    fields = {
        "doc_book": "File: A directory of Docbook output.",
        "html": "File: A directory of HTML output.",
        "latex": "File: A directory of latex output.",
        "man_page": "File: A directory of man page output.",
        "rtf": "File: A directory of RTF output.",
        "xml": "File: A directory of XML output.",
    },
)

DoxygenInputsInfo = provider(
    doc = "A container of collected source files from `doxygen_inputs_aspect",
    fields = {
        "srcs": "Depset[File]: Collected source files",
    },
)

def _doxygen_inputs_aspect_impl(target, ctx):
    if DoxygenInputsInfo in target:
        return []

    srcs = []
    for src_attr in ["srcs", "hdrs"]:
        srcs.extend(getattr(ctx.rule.files, src_attr, []))

    return [DoxygenInputsInfo(
        srcs = depset(sorted(srcs)),
    )]

doxygen_inputs_aspect = aspect(
    doc = "An aspect for collecting source files from `doxygen.target`.",
    implementation = _doxygen_inputs_aspect_impl,
)

_OUTPUTS = ["html", "latex", "rtf", "xml", "man_page", "doc_book"]

def _doxygen_impl(ctx):
    html = None
    latex = None
    rtf = None
    xml = None
    man_page = None
    doc_book = None
    config = ctx.actions.declare_file("{}.doxygen.cfg".format(ctx.label.name))

    outputs = []
    output_group_info = {"doxygen_config": depset([config])}
    args = ctx.actions.args()

    args.add("--config", config)
    args.add("--base_config", ctx.file.config)
    args.add("--project_name", ctx.attr.project_name if ctx.attr.project_name else ctx.attr.target.label.name)

    output = ctx.attr.output
    if output == "html":
        html = ctx.actions.declare_directory(ctx.label.name)
        args.add("--html", html.path)
        outputs.append(html)
        output_group_info.update({"doxygen_html": depset([html])})
    elif output == "latex":
        latex = ctx.actions.declare_directory(ctx.label.name)
        args.add("--latex", latex.path)
        outputs.append(latex)
        output_group_info.update({"doxygen_latex": depset([latex])})
    elif output == "rtf":
        rtf = ctx.actions.declare_directory(ctx.label.name)
        args.add("--rtf", rtf.path)
        outputs.append(rtf)
        output_group_info.update({"doxygen_rtf": depset([rtf])})
    elif output == "xml":
        xml = ctx.actions.declare_directory(ctx.label.name)
        args.add("--xml", xml.path)
        outputs.append(xml)
        output_group_info.update({"doxygen_xml": depset([xml])})
    elif output == "man_page":
        man_page = ctx.actions.declare_directory(ctx.label.name)
        args.add("--man_page", man_page.path)
        outputs.append(man_page)
        output_group_info.update({"doxygen_man_page": depset([man_page])})
    elif output == "doc_book":
        doc_book = ctx.actions.declare_directory(ctx.label.name)
        args.add("--doc_book", doc_book.path)
        outputs.append(doc_book)
        output_group_info.update({"doxygen_doc_book": depset([doc_book])})
    else:
        fail("Unexpected output: {}\nExpected one of {}".format(
            output,
            _OUTPUTS,
        ))

    doxygen_toolchain = ctx.toolchains[Label("//doxygen:toolchain_type")]

    args.add("--doxygen", doxygen_toolchain.doxygen)

    target = ctx.attr.target
    inputs_info = target[DoxygenInputsInfo]

    args.add("--inputs")
    inputs_args = ctx.actions.args().use_param_file("%s", use_always = True)
    inputs_args.add_all(inputs_info.srcs)

    ctx.actions.run(
        outputs = outputs + [config],
        inputs = depset([ctx.file.config] + ctx.files.data, transitive = [inputs_info.srcs]),
        executable = ctx.executable._runner,
        mnemonic = "Doxygen",
        tools = depset([doxygen_toolchain.all_files]),
        arguments = [args, inputs_args],
    )

    return [
        DefaultInfo(
            files = depset(outputs),
        ),
        DoxygenInfo(
            html = html,
            latex = latex,
            rtf = rtf,
            xml = xml,
            man_page = man_page,
            doc_book = doc_book,
        ),
        OutputGroupInfo(
            **output_group_info
        ),
    ]

doxygen = rule(
    doc = "Generate documentation for C/C++ targets using doxygen.",
    implementation = _doxygen_impl,
    attrs = {
        "config": attr.label(
            doc = "The doxygen config file.",
            allow_single_file = True,
            default = Label("//doxygen:config"),
        ),
        "data": attr.label_list(
            doc = "Additional source files to add to the Doxygen action.",
            allow_files = True,
        ),
        "output": attr.string(
            doc = "The type of output to produce.",
            values = _OUTPUTS,
            default = "html",
        ),
        "project_name": attr.string(
            doc = "An optional project name to use. If unset, the label name of `target` will be used.",
        ),
        "target": attr.label(
            doc = "The C/C++ target to generate documentation for",
            providers = [CcInfo],
            mandatory = True,
            aspects = [doxygen_inputs_aspect],
        ),
        "_runner": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("//doxygen/private:doxygen_action_runner"),
        ),
    },
    toolchains = [str(Label("//doxygen:toolchain_type"))],
)

def _rlocationpath(file):
    if file.short_path.startswith("../"):
        return file.short_path[len("../"):]

    workspace_name = file.owner.workspace_name
    if not workspace_name:
        workspace_name = "rules_doxygen"
    return "{}/{}".format(workspace_name, file.short_path).lstrip("/")

def _doxygen_runner_impl(ctx):
    runner = ctx.executable._runner
    executable = ctx.actions.declare_file("{}{}".format(ctx.label.name, runner.extension))
    ctx.actions.symlink(
        output = executable,
        target_file = runner,
        is_executable = True,
    )

    doxygen_toolchain = ctx.toolchains[Label("//doxygen:toolchain_type")]

    runfiles = ctx.runfiles([ctx.file.config, runner], transitive_files = doxygen_toolchain.all_files)
    runfiles = runfiles.merge(ctx.attr._runner[DefaultInfo].default_runfiles)

    return [
        DefaultInfo(
            files = depset([executable]),
            runfiles = runfiles,
            executable = executable,
        ),
        RunEnvironmentInfo(
            environment = {
                "DOXYGEN": _rlocationpath(doxygen_toolchain.doxygen),
                "DOXYGEN_CONFIG": _rlocationpath(ctx.file.config),
            },
        ),
    ]

doxygen_runner = rule(
    doc = "A rule defining a doxygen exectuable that runs on a config from the root of the current workspace.",
    implementation = _doxygen_runner_impl,
    attrs = {
        "config": attr.label(
            doc = "The doxygen config file.",
            allow_single_file = True,
            default = Label("//doxygen:config"),
        ),
        "_runner": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("//doxygen/private:doxygen_runner"),
        ),
    },
    toolchains = [str(Label("//doxygen:toolchain_type"))],
    executable = True,
)

def _doxygen_toolchain_impl(ctx):
    bin_default_info = ctx.attr.doxygen[DefaultInfo]
    all_files = depset(transitive = [
        bin_default_info.files,
        bin_default_info.default_runfiles.files,
    ])

    return platform_common.ToolchainInfo(
        doxygen = ctx.executable.doxygen,
        all_files = all_files,
    )

doxygen_toolchain = rule(
    doc = "A toolchain used to power doxygen rules.",
    implementation = _doxygen_toolchain_impl,
    attrs = {
        "doxygen": attr.label(
            doc = "The doxygen binary.",
            allow_files = True,
            executable = True,
            cfg = "exec",
            mandatory = True,
        ),
    },
)
