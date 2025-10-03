cmake_minimum_required(VERSION 3.13)

project(icarus_prime LANGUAGES C CXX ASM)

# Allow overriding the toolchain by setting environment variables or cmake vars
if(NOT CMAKE_C_COMPILER)
  set(CMAKE_C_COMPILER "arm-none-eabi-gcc")
endif()
if(NOT CMAKE_CXX_COMPILER)
  set(CMAKE_CXX_COMPILER "arm-none-eabi-g++")
endif()
if(NOT OBJCOPY)
  set(OBJCOPY "arm-none-eabi-objcopy")
endif()

# Target architecture and common flags for STM32F103 (Cortex-M3)
set(MCU_FLAGS "-mcpu=cortex-m3 -mthumb")
set(COMMON_FLAGS "-Wall -Wextra -ffunction-sections -fdata-sections -g ${MCU_FLAGS}")
set(CMAKE_C_FLAGS "${COMMON_FLAGS} -std=gnu11")
set(CMAKE_CXX_FLAGS "${COMMON_FLAGS} -std=gnu++11")
set(CMAKE_EXE_LINKER_FLAGS "-Wl,--gc-sections ${MCU_FLAGS}")

# Optimization and defines
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()
if(CMAKE_BUILD_TYPE STREQUAL "Release")
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O2")
else()
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O0 -Og")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O0 -Og")
endif()

# Source directories
set(CORE_DIR "${CMAKE_SOURCE_DIR}/Core")
set(DRIVERS_DIR "${CMAKE_SOURCE_DIR}/Drivers")

# Collect sources
set(SOURCES
  ${CORE_DIR}/Src/main.c
  ${CORE_DIR}/Src/stm32f1xx_hal_msp.c
  ${CORE_DIR}/Src/stm32f1xx_it.c
  ${CORE_DIR}/Src/syscalls.c
  ${CORE_DIR}/Src/sysmem.c
  ${CORE_DIR}/Src/system_stm32f1xx.c
  ${CORE_DIR}/Startup/startup_stm32f103c8tx.s
)

# HAL driver sources
list(APPEND SOURCES
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_cortex.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_dma.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_exti.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_flash_ex.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_gpio_ex.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_pwr.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc.c
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Src/stm32f1xx_hal_rcc_ex.c
)

# Include directories
include_directories(
  ${CORE_DIR}/Inc
  ${DRIVERS_DIR}/STM32F1xx_HAL_Driver/Inc
  ${DRIVERS_DIR}/CMSIS/Include
  ${DRIVERS_DIR}/CMSIS/Device/ST/STM32F1xx/Include
)

# Output
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Define the firmware target
add_executable(icarus_prime.elf ${SOURCES})

# Linker script (present at repo root)
set(LINKER_SCRIPT "${CMAKE_SOURCE_DIR}/STM32F103C8TX_FLASH.ld")
if(EXISTS ${LINKER_SCRIPT})
  target_link_options(icarus_prime.elf PRIVATE "-T${LINKER_SCRIPT}")
else()
  message(WARNING "Linker script ${LINKER_SCRIPT} not found. Please add it to the project root.")
endif()

# Pass flags to target
target_compile_options(icarus_prime.elf PRIVATE ${CMAKE_C_FLAGS} ${CMAKE_CXX_FLAGS})
target_link_libraries(icarus_prime.elf PRIVATE m)

# Post-build: create binary and hex
add_custom_command(TARGET icarus_prime.elf POST_BUILD
  COMMAND ${OBJCOPY} -O binary $<TARGET_FILE:icarus_prime.elf> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/icarus_prime.bin
  COMMAND ${OBJCOPY} -O ihex $<TARGET_FILE:icarus_prime.elf> ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/icarus_prime.hex
  COMMENT "Generating .bin and .hex files"
)

message(STATUS "Configured icarus_prime target. Build with: cmake -S . -B build && cmake --build build")
