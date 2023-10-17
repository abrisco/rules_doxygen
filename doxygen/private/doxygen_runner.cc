/**
 * @file doxygen_runner.cc
 * @author Andre Brisco
 * @brief The runner for doxygen outside of a Bazel action.
 *
 */

#include <iostream>
#include <memory>
#include <string>

#if defined(_WIN32)
#include <direct.h>
#define chdir _chdir
#else
#include <unistd.h>
#endif

#include "tools/cpp/runfiles/runfiles.h"

/**
 * @brief The main entrypoint
 *
 */
int main(int argc, char** argv) {
    std::string error = {};
    std::unique_ptr<bazel::tools::cpp::runfiles::Runfiles> runfiles(
        bazel::tools::cpp::runfiles::Runfiles::Create(argv[0], &error));

    if (runfiles == nullptr) {
        std::cerr << "ERROR: Failed to create runfiles object." << std::endl;
        return -1;
    }

    std::string doxygen = {};
    if (const char* var = std::getenv("DOXYGEN")) {
        doxygen = runfiles->Rlocation(var);
    } else {
        std::cerr << "ERROR: No `DOXYGEN` environment variable set."
                  << std::endl;
        std::exit(-1);
    }

    std::string config = {};
    if (const char* var = std::getenv("DOXYGEN_CONFIG")) {
        config = runfiles->Rlocation(var);
    } else {
        std::cerr << "ERROR: No `DOXYGEN_CONFIG` environment variable set."
                  << std::endl;
        std::exit(-1);
    }

    std::string build_workspace_directory = {};
    if (const char* var = std::getenv("BUILD_WORKSPACE_DIRECTORY")) {
        build_workspace_directory = runfiles->Rlocation(var);
    } else {
        std::cerr
            << "ERROR: No `BUILD_WORKSPACE_DIRECTORY` environment variable set."
            << std::endl;
        std::exit(-1);
    }

    if (chdir(build_workspace_directory.c_str())) {
        std::cerr << "ERROR: Failed change directories." << std::endl;
        std::exit(-1);
    }

    std::string command = doxygen + " " + config;
    for (int i = 1; i < argc; ++i) {
        command += " " + std::string(argv[i]);
    }

    std::cout << command << std::endl;
    if (std::system(command.c_str())) {
        return -1;
    }

    return 0;
}
