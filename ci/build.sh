#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Locating repository root and build directory ---"
# Resolve the directory where this script lives (repo root assumed one level up)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
echo "Script dir: $SCRIPT_DIR"
echo "Repo root: $REPO_ROOT"

# Desired build directory
BUILD_DIR="$REPO_ROOT/icarus_prime/Debug"

echo "--- Navigating to Build Directory: $BUILD_DIR ---"
cd "$BUILD_DIR"

echo "--- Compiling Project with Make ---"

# Run the make command to build all targets using 9 parallel jobs
make -j9 all

echo "--- Build Successful ---"

# List the output files in the current directory to verify the firmware was created.
echo "--- Build Artifacts ---"
ls -l .