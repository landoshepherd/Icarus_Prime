# Start with a stable Ubuntu base image
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential tools
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    unzip \
    libncurses5 \
    && rm -rf /var/lib/apt/lists/*

# --- Install the ARM GCC Toolchain ---
# Update the URL for the version you need from Arm's developer website
ENV ARM_TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz"
RUN wget -qO- "${ARM_TOOLCHAIN_URL}" | tar -xJ -C /opt \
    && ln -s /opt/arm-gnu-toolchain-*/bin/* /usr/local/bin/

# --- Install STM32CubeIDE Headlessly ---
# This is a large file. Update the URL for the version you need from ST.com.
ENV CUBEIDE_INSTALLER_URL="https://dl.st.com/st-web-ui/STM32CubeIDE/1.15.1/en.st-stm32cubeide_1.15.1_21096_20240412_1049_amd64.deb_bundle.sh"
ENV CUBEIDE_DIR="/opt/st/stm32cubeide_1.15.1"

RUN wget -qO /tmp/cubeide_installer.sh "${CUBEIDE_INSTALLER_URL}" \
    && chmod +x /tmp/cubeide_installer.sh \
    # Run the installer in silent mode to avoid GUI prompts
    && /tmp/cubeide_installer.sh --accept-licenses --silent \
    && rm /tmp/cubeide_installer.sh

# Set the working directory for the project code
WORKDIR /project