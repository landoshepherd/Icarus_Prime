#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

BUILD_SUBDIR="Debug"
BUILD_DIR="$REPO_ROOT/icarus_prime/$BUILD_SUBDIR"

TOOLCHAIN_FILE="$REPO_ROOT/icarus_prime/toolchain-arm-none-eabi.cmake"

echo "Script dir: $SCRIPT_DIR"
echo "Repo root: $REPO_ROOT"
echo "Build dir: $BUILD_DIR"

if [ ! -d "$BUILD_DIR" ] || [ ! -f "$BUILD_DIR/Makefile" ]; then
	echo "Configuring project with CMake (Debug)"
	if [ -f "$TOOLCHAIN_FILE" ]; then
		cmake -S "$REPO_ROOT/icarus_prime" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE="$TOOLCHAIN_FILE"
	else
		echo "Warning: toolchain file not found at $TOOLCHAIN_FILE; running cmake without toolchain file"
		cmake -S "$REPO_ROOT/icarus_prime" -B "$BUILD_DIR" -DCMAKE_BUILD_TYPE=Debug
	fi
fi

echo "Navigating to build dir and building"
cd "$BUILD_DIR"
ls -l

echo "--- Compiling Project with Make ---"
make -j9 all

echo "--- Build Successful ---"

echo "--- Build Artifacts ---"
ls -l .
echo $PWD