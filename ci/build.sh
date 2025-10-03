#!/bin/bash
# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- Navigating to Build Directory ---"
echo $PWD
# Change to the directory containing the Makefile
cd ./icarus_prime/Debug/

echo "--- Compiling Project with Make ---"

# Run the make command to build all targets using 9 parallel jobs
make -j9 all

echo "--- Build Successful ---"

# List the output files in the current directory to verify the firmware was created.
echo "--- Build Artifacts ---"
ls -l .