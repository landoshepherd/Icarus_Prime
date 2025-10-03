#!/bin/bash
# Exit immediately if a command fails
set -e

echo "--- Starting Headless Build ---"

# Path to the STM32CubeIDE headless builder executable inside the Docker container
CUBE_IDE_HEADLESS="$CUBEIDE_DIR/stm32cubeidec"

# The name of your project as it appears in STM32CubeIDE
# IMPORTANT: Change this to your actual project folder name
PROJECT_NAME="icarus_prime"
BUILD_CONFIG="Release" # Or "Release"

# Build the project using the headless application
$CUBE_IDE_HEADLESS --launcher.suppressErrors -nosplash \
-application org.eclipse.cdt.managedbuilder.core.headlessbuild \
-import . \
-build "${PROJECT_NAME}/${BUILD_CONFIG}"

echo "--- Build Successful ---"

# List the output files to verify
echo "--- Build Artifacts ---"
ls -l "${BUILD_CONFIG}/"
