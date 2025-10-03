#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# --- 1. Define Build Configuration ---
BUILD_DIR="build"
BUILD_TYPE="Release" # Can be switched to "Debug"

echo "--- Configuring Project with CMake ---"

# This command creates a 'build' directory, configures the project,
# and generates the Makefiles inside it.
cmake -S . -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE="$BUILD_TYPE"

echo "--- Compiling Project ---"

# This command runs the underlying 'make' command from within the build directory.
cmake --build "$BUILD_DIR"

echo "--- Build Successful ---"

# List the output files to verify the firmware was created.
echo "--- Build Artifacts in '$BUILD_DIR' ---"
ls -l "$BUILD_DIR"