### Minimal CMake toolchain file for NUCLEO-F446RE (STM32F446RE)
### Adjusts CPU/float settings for the board's Cortex-M4 + FPU

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Cross compiler
set(CMAKE_C_COMPILER   arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)

# Tools
set(CMAKE_OBJCOPY       arm-none-eabi-objcopy)
set(CMAKE_OBJDUMP       arm-none-eabi-objdump)
set(CMAKE_SIZE          arm-none-eabi-size)

# Target MCU (used for defines / informational)
# Default is NUCLEO-F446RE -> STM32F446RE (Cortex-M4 with single-precision FPU)
set(TARGET_MCU "STM32F446RE" CACHE STRING "Target MCU for this toolchain")

# Default CPU / FPU / ABI flags for NUCLEO-F446RE
# You can override these cache variables before including this file if needed.
if(NOT DEFINED CORTEX_M_CPU_FLAGS)
  set(CORTEX_M_CPU_FLAGS "-mcpu=cortex-m4 -mthumb" CACHE STRING "CPU flags for Cortex-M")
endif()

if(NOT DEFINED CORTEX_M_FPU_FLAGS)
  # STM32F446RE has an FPU (single-precision, 16 registers)
  # Default uses hard-float. If your toolchain is softfp/soft, override this to match.
  set(CORTEX_M_FPU_FLAGS "-mfpu=fpv4-sp-d16 -mfloat-abi=hard" CACHE STRING "FPU flags for Cortex-M")
endif()

# Common optimization / linker flags
if(NOT DEFINED MCU_COMMON_FLAGS)
  set(MCU_COMMON_FLAGS "-ffunction-sections -fdata-sections" CACHE STRING "Common MCU compiler flags")
endif()

# Compose full flags
set(CMAKE_C_FLAGS "${CORTEX_M_CPU_FLAGS} ${CORTEX_M_FPU_FLAGS} ${MCU_COMMON_FLAGS}")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")
set(CMAKE_ASM_FLAGS "${CORTEX_M_CPU_FLAGS} ${CORTEX_M_FPU_FLAGS}")

# Linker flags: keep garbage-collecting unused sections. User should provide a linker script via
# target_link_options or set CMAKE_EXE_LINKER_FLAGS further in their project if needed.
set(CMAKE_EXE_LINKER_FLAGS "${CORTEX_M_CPU_FLAGS} ${CORTEX_M_FPU_FLAGS} -Wl,--gc-sections")

# Provide a preprocessor define for the MCU family so sources can #ifdef accordingly
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -D${TARGET_MCU}")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D${TARGET_MCU}")

# Tell CMake not to search for an SDK sysroot
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# When cross-compiling for bare-metal targets, CMake's try_compile may
# attempt to link test executables which require host libc functions like
# _exit. Force try-compile to build static libraries instead to avoid
# calling the linker for test executables.
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Helpful message when included
message(STATUS "Toolchain: arm-none-eabi for ${TARGET_MCU}")
message(STATUS "C flags: ${CMAKE_C_FLAGS}")
message(STATUS "Linker flags: ${CMAKE_EXE_LINKER_FLAGS}")