# Start with a stable base image
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential build tools (make, wget) and dependencies for CMake
RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    unzip \
    cmake \
    libncurses5 \
    && rm -rf /var/lib/apt/lists/*

# --- Install ARM GCC Toolchain ---
# You can update the URL for the version you need from Arm's developer website
ENV ARM_TOOLCHAIN_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz"

RUN wget -qO- "${ARM_TOOLCHAIN_URL}" | tar -xJ -C /opt \
    && ln -s /opt/arm-gnu-toolchain-*/bin/* /usr/local/bin/

# Set the working directory for our project code
WORKDIR /Icarus_Prime