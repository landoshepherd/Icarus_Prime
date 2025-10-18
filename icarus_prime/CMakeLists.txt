cmake_minimum_required(VERSION 3.13)
project(icarus_prime LANGUAGES C CXX ASM)

# --- Target hardware: NUCLEO-F446RE ---
# This CMakeLists is tailored for the STM32F446RE (Cortex-M4 with FPU).

# --- Define the Executable and its Source Files ---
# Listing sources explicitly is a great practice for reliability.
file(GLOB_RECURSE SOURCES
    "Core/Src/*.c"
    "Core/Startup/*.s"
    "Drivers/STM32F4xx_HAL_Driver/Src/*.c"
)
add_executable(icarus_prime.elf ${SOURCES})


# --- Target-Specific Include Directories ---
# This is the modern way to add include paths per-target.
target_include_directories(icarus_prime.elf PRIVATE
    Core/Inc
    Drivers/STM32F4xx_HAL_Driver/Inc
    Drivers/CMSIS/Include
    Drivers/CMSIS/Device/ST/STM32F4xx/Include
)

# --- MCU Flags (Cortex-M4, hardware FPU) ---
# Use a variable for all MCU-specific flags to keep compiler and linker options in sync.
set(MCU_FLAGS
    -mcpu=cortex-m4
    -mthumb
    -mfpu=fpv4-sp-d16
    -mfloat-abi=hard
)

# --- Target-Specific Compiler Flags ---
target_compile_options(icarus_prime.elf PRIVATE
    ${MCU_FLAGS}
    -Wall
    -Wextra
    -ffunction-sections
    -fdata-sections
    -g
)
# Add build-type specific flags
target_compile_options(icarus_prime.elf PRIVATE
    $<$<CONFIG:Release>:-O2>
    $<$<CONFIG:Debug>:-O0;-Og>
)

target_compile_definitions(icarus_prime.elf PRIVATE
    STM32F446xx
    USE_HAL_DRIVER
)

# --- Target-Specific Linker Options ---
# Set the linker script for the target (NUCLEO-F446RE). Update path/name if your repo stores it elsewhere.
set(LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/STM32F446RETX_FLASH.ld")
if(EXISTS ${LINKER_SCRIPT})
    target_link_options(icarus_prime.elf PRIVATE
        -T${LINKER_SCRIPT}
        -Wl,--gc-sections
        ${MCU_FLAGS}
    )
else()
    message(WARNING "Linker script ${LINKER_SCRIPT} not found.")
endif()

# --- Optional: generate map file (uncomment if desired) ---
# target_link_options(icarus_prime.elf PRIVATE -Wl,-Map,$<TARGET_FILE:icarus_prime>.map)

# --- Post-build Commands ---
add_custom_command(TARGET icarus_prime.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:icarus_prime.elf> $<TARGET_FILE_DIR:icarus_prime.elf>/icarus_prime.bin
  COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:icarus_prime.elf> $<TARGET_FILE_DIR:icarus_prime.elf>/icarus_prime.hex
  COMMENT "Generating .bin and .hex files"
)
