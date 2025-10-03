#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

# Desired build directory
BUILD_DIR="icarus_prime/Debug"

echo "--- Navigating to Build Directory: $BUILD_DIR ---"

ls -l
cd "$BUILD_DIR"

echo "--- Compiling Project with Make ---"

# Run the make command to build all targets using 9 parallel jobs
make -j9 all

echo "--- Build Successful ---"

# List the output files in the current directory to verify the firmware was created.
echo "--- Build Artifacts ---"
ls -l .