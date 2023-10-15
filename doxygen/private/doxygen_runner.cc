/**
 * @file doxygen_runner.cc
 * @author Andre Brisco
 * @brief The action runner for rules_doxygen Bazel rules.
 *
 */

#include <stdio.h>

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <regex>
#include <string>

#if defined(_WIN32)
#define popen _popen
#define pclose _pclose
#endif

/**
 * @brief A container for command line arguments.
 *
 */
struct Arguments {
    std::vector<std::string> inputs;
    std::string doxygen;
    std::string config;
    std::string base_config;
    std::string project_name;
    std::string html;
    std::string latex;
    std::string rtf;
    std::string xml;
    std::string man_page;
    std::string doc_book;

    /**
     * @brief Parse command line arguments.
     *
     * @param argc The number of command line arguments.
     * @param argv A pointer to command line arguments
     * @return A new `Arguments` struct.
     */
    static Arguments parse(int argc, char** argv) {
        Arguments args = Arguments();

        for (int i = 1; i < argc; ++i) {
            std::string arg = argv[i];
            if (++i == argc) {
                std::cerr << "ERROR: argument \"" << arg
                          << "\" missing parameter." << std::endl;
                std::exit(-1);
            }

            if (arg == "--doxygen") {
                args.doxygen = argv[i];
            } else if (arg == "--config") {
                args.config = argv[i];
            } else if (arg == "--base_config") {
                args.base_config = argv[i];
            } else if (arg == "--project_name") {
                args.project_name = argv[i];
            } else if (arg == "--inputs") {
                std::string inputs_path = argv[i];
                std::string line;
                std::ifstream inputs_stream(inputs_path);
                while (getline(inputs_stream, line)) {
                    args.inputs.push_back(line);
                }
            } else if (arg == "--html") {
                args.html = argv[i];
            } else if (arg == "--latex") {
                args.latex = argv[i];
            } else if (arg == "--rtf") {
                args.rtf = argv[i];
            } else if (arg == "--xml") {
                args.xml = argv[i];
            } else if (arg == "--man_page") {
                args.man_page = argv[i];
            } else if (arg == "--doc_book") {
                args.doc_book = argv[i];
            } else {
                std::cerr << "ERROR: unknow argument \"" << arg << "\"."
                          << std::endl;
                std::exit(-1);
            }
        }

        if (args.doxygen.empty() || args.config.empty() ||
            args.base_config.empty() || args.inputs.size() == 0) {
            std::cerr
                << "ERROR: Missing required argument. `--doxygen`, `--config`, "
                   "`--inputs`, and `--base_config` must be provided"
                << std::endl;
            std::exit(-1);
        }

        if (args.html.empty() && args.latex.empty() && args.rtf.empty() &&
            args.xml.empty() && args.xml.empty() && args.man_page.empty() &&
            args.doc_book.empty()) {
            std::cerr << "ERROR: No output specified." << std::endl;
            std::exit(-1);
        }

        return args;
    }
};

#define DOXYGEN_DOCBOOK_OUTPUT "DOCBOOK_OUTPUT"
#define DOXYGEN_HTML_OUTPUT "HTML_OUTPUT"
#define DOXYGEN_INPUT "INPUT"
#define DOXYGEN_LATEX_OUTPUT "LATEX_OUTPUT"
#define DOXYGEN_MAN_OUTPUT "MAN_OUTPUT"
#define DOXYGEN_OUTPUT_DIRECTORY "OUTPUT_DIRECTORY"
#define DOXYGEN_PROJECT_NAME "PROJECT_NAME"
#define DOXYGEN_RTF_OUTPUT "RTF_OUTPUT"
#define DOXYGEN_XML_OUTPUT "XML_OUTPUT"

const static std::string ILLEGAL_CONFIG_VALUES[] = {
    DOXYGEN_DOCBOOK_OUTPUT, DOXYGEN_HTML_OUTPUT, DOXYGEN_INPUT,
    DOXYGEN_LATEX_OUTPUT,   DOXYGEN_MAN_OUTPUT,  DOXYGEN_OUTPUT_DIRECTORY,
    DOXYGEN_RTF_OUTPUT,     DOXYGEN_XML_OUTPUT,
};

/**
 * @brief Write a doxygen config that's configured for the current action.
 *
 * @param new_config The output path of the new config file.
 * @param existing_config The path to the existing config file.
 * @param project_name The project name to set in the config file
 * @param html The location of the HTML output directory.
 * @param latex The location of the Latex output directory.
 * @param rtf The location of the RTF output directory.
 * @param xml The location of the XML output directory.
 * @param man_page The location of the man page output directory.
 * @param doc_book The location of the Docbook output directory.
 * @param inputs All inputs to doxygen from a C/C++ target.
 */
void render_config(const std::string& new_config,
                   const std::string& existing_config,
                   const std::string& project_name, const std::string& html,
                   const std::string& latex, const std::string& rtf,
                   const std::string& xml, const std::string& man_page,
                   const std::string& doc_book,
                   const std::vector<std::string>& inputs) {
    std::string line;
    std::ofstream new_stream(new_config);
    std::ifstream existing_stream(existing_config);

    if (!new_stream.is_open()) {
        std::cerr << "New file is not open: " << new_config << std::endl;
        std::exit(-1);
    }

    if (!existing_stream.is_open()) {
        std::cerr << "Existing file is not open: " << existing_config
                  << std::endl;
        std::exit(-1);
    }

    while (getline(existing_stream, line)) {
        // Skip all config values that should be controlled by Bazel
        for (const std::string& str : ILLEGAL_CONFIG_VALUES) {
            std::regex pattern(str, std::regex::extended);
            if (std::regex_search(line, pattern)) {
                continue;
            }
        }

        // If a project name is specified omit the existing one.
        if (!project_name.empty()) {
            std::regex pattern(DOXYGEN_PROJECT_NAME, std::regex::extended);
            if (std::regex_search(line, pattern)) {
                continue;
            }
        }

        new_stream << line << "\n";
    }
    existing_stream.close();

    new_stream << "############################################################"
                  "####################\n";
    new_stream << "## Bazel rules_doxygen generated configuration\n";
    new_stream << "############################################################"
                  "####################\n";

    if (!project_name.empty()) {
        new_stream << DOXYGEN_PROJECT_NAME << " = " << project_name << "\n";
    }
    if (!html.empty()) {
        new_stream << DOXYGEN_HTML_OUTPUT << " = " << html << "\n";
    }
    if (!latex.empty()) {
        new_stream << DOXYGEN_LATEX_OUTPUT << " = " << latex << "\n";
    }
    if (!rtf.empty()) {
        new_stream << DOXYGEN_RTF_OUTPUT << " = " << rtf << "\n";
    }
    if (!xml.empty()) {
        new_stream << DOXYGEN_XML_OUTPUT << " = " << xml << "\n";
    }
    if (!man_page.empty()) {
        new_stream << DOXYGEN_MAN_OUTPUT << " = " << man_page << "\n";
    }
    if (!doc_book.empty()) {
        new_stream << DOXYGEN_DOCBOOK_OUTPUT << " = " << doc_book << "\n";
    }

    std::string inputs_str = "";
    for (const std::string& str : inputs) {
        inputs_str += str + " \\\n";
    }
    new_stream << DOXYGEN_INPUT << " = " << inputs_str << "\n";

    new_stream.close();
}

/**
 * @brief Run the doxygen process
 *
 * @param doxygen The doxygen binary.
 * @param config The config file.
 * @param out_stream An output variable to capture the output streams of the
 * system call.
 * @return The exit code of the system call.
 */
int run_doxygen(const std::string& doxygen, const std::string& config,
                std::string& out_stream) {
    std::string command = doxygen + " " + config;

    char buffer[1024];
    FILE* pipe = popen(command.c_str(), "r");
    if (pipe == nullptr) {
        return -1;
    }

    while (fgets(buffer, sizeof buffer, pipe) != nullptr) {
        out_stream += buffer;
    }

    return pclose(pipe);
}

/**
 * @brief The main entrypoint
 *
 */
int main(int argc, char** argv) {
    // Parse arguments
    Arguments args = Arguments::parse(argc, argv);

    // Render a new config with the appropriate values
    render_config(args.config, args.base_config, args.project_name, args.html,
                  args.latex, args.rtf, args.xml, args.man_page, args.doc_book,
                  args.inputs);

    // Run Doxygen
    std::string stream = {};
    int result = run_doxygen(args.doxygen, args.config, stream);
    if (result != 0) {
        std::cerr << stream << std::endl;
        return -1;
    }

    return 0;
}
