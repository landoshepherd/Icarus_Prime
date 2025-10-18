cmake_minimum_required(VERSION 3.13)
project(icarus_prime LANGUAGES C CXX ASM)

# --- Define the Executable and its Source Files ---
# Listing sources explicitly is a great practice for reliability.
file(GLOB_RECURSE SOURCES
    "Core/Src/*.c"
    "Core/Startup/*.s"
    "Drivers/STM32F1xx_HAL_Driver/Src/*.c"
)
add_executable(icarus_prime.elf ${SOURCES})


# --- Target-Specific Include Directories ---
# This is the modern way to add include paths per-target.
target_include_directories(icarus_prime.elf PRIVATE
    Core/Inc
    Drivers/STM32F1xx_HAL_Driver/Inc
    Drivers/CMSIS/Include
    Drivers/CMSIS/Device/ST/STM32F1xx/Include
)

# --- Target-Specific Compiler Flags ---
# Apply all compiler flags directly to the target.
target_compile_options(icarus_prime.elf PRIVATE
    -mcpu=cortex-m3
    -mthumb
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
	STM32F103xB
	USE_HAL_DRIVER
)

# --- Target-Specific Linker Options ---
# Set the linker script for the target.
set(LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/STM32F446RETX_FLASH.ld")
if(EXISTS ${LINKER_SCRIPT})
    target_link_options(icarus_prime.elf PRIVATE
        -T${LINKER_SCRIPT}
        -Wl,--gc-sections
        -mcpu=cortex-m3 # Linker also needs to know the CPU
        -mthumb
    )
else()
    message(WARNING "Linker script ${LINKER_SCRIPT} not found.")
endif()

# --- Post-build Commands ---
add_custom_command(TARGET icarus_prime.elf POST_BUILD
  COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:icarus_prime.elf> $<TARGET_FILE_DIR:icarus_prime.elf>/icarus_prime.bin
  COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:icarus_prime.elf> $<TARGET_FILE_DIR:icarus_prime.elf>/icarus_prime.hex
  COMMENT "Generating .bin and .hex files"
)