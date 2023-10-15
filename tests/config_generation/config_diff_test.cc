/**
 * @file config_diff_test.cc
 * @author your name (you@domain.com)
 * @brief The test runner for ensuring generated doxygen config files match
 * certain expectations
 * @version 0.1
 * @date 2023-10-15
 *
 * @copyright Copyright (c) 2023
 *
 */

#include <fstream>
#include <iostream>
#include <memory>
#include <regex>
#include <string>

#include "tools/cpp/runfiles/runfiles.h"

/**
 * @brief The regex pattern to check the input file against.
 *
 * @details This pattern is expected to match patterns like the following:
 *
 * ```
 * PROJECT_NAME = binary
 * HTML_OUTPUT =
 * bazel-out/darwin_arm64-fastbuild/bin/tests/config_generation/binary_docs
 * INPUT = \
 *     tests/config_generation/config_diff_test.cc
 * ```
 */
static const char* EXPECTED_PATTERN =
    "PROJECT_NAME = binary\nHTML_OUTPUT = "
    "bazel-out/[a-z-_0-9]+/bin/tests/config_generation/binary_docs\nINPUT = "
    "\\\\\n\\s+tests/config_generation/config_diff_test\\.cc";

/**
 * @brief Read the contents of a file to a string
 *
 * @param path The file to read.
 * @return The contents of the file
 */
std::string read_to_string(const std::string& path) {
    std::ifstream stream(path);
    std::string content((std::istreambuf_iterator<char>(stream)),
                        (std::istreambuf_iterator<char>()));
    return content;
}

/**
 * @brief The main entrypoint.
 *
 */
int main(int argc, char** argv) {
    std::string error;
    std::unique_ptr<bazel::tools::cpp::runfiles::Runfiles> runfiles(
        bazel::tools::cpp::runfiles::Runfiles::CreateForTest(
            BAZEL_CURRENT_REPOSITORY, &error));

    if (runfiles == nullptr) {
        std::cerr << "ERROR: Failed to create runfiles object" << std::endl;
        return -1;
    }
    std::string config = runfiles->Rlocation(argv[1]);
    std::string content = read_to_string(config);

    std::regex pattern(std::string(EXPECTED_PATTERN),
                       std::regex_constants::ECMAScript);
    if (!std::regex_search(content, pattern)) {
        std::cerr
            << "ERROR: The generated doxygen config did not match expectations"
            << std::endl;
        std::cerr << content << std::endl;
        return -1;
    }

    return 0;
}
