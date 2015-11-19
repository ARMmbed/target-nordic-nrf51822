# Copyright (c) 2015 ARM Limited
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if(TARGET_NORDIC_NRF51822_ARMCC_TOOLCHAIN_INCLUDED)
    return()
endif()
set(TARGET_NORDIC_NRF51822_ARMCC_TOOLCHAIN_INCLUDED 1)

# If the memory size has not been defined then default to 16K and print a warning
# otherwise ensure that the string is uppercase to build the macro definitions correctly
if(NOT YOTTA_CFG_NRF51822_RAM_SIZE)
    message(WARNING "No definition of YOTTA_CFG_NRF51822_RAM_SIZE found, building image for default 16K target.")
    set(YOTTA_CFG_NRF51822_RAM_SIZE "16K")
else()
    # Ensure that the string is uppercase to build the macro definitions correctly
    string(TOUPPER "${YOTTA_CFG_NRF51822_RAM_SIZE}" YOTTA_CFG_NRF51822_RAM_SIZE)
    if(NOT (YOTTA_CFG_NRF51822_RAM_SIZE STREQUAL "16K") AND NOT (YOTTA_CFG_NRF51822_RAM_SIZE STREQUAL "16K"))
        # Fail if the RAM size is not supported
        message(FATAL_ERROR "Cannot build image for target with RAM size '${YOTTA_CFG_NRF51822_RAM_SIZE}'. Please modify your yotta config to set YOTTA_CFG_NRF51822_RAM_SIZE a supported option.\nSupported RAM sizes: '16K' (default), '32K'.")
    endif()
endif()

# Set S130 as the default SoftDevice if not defined through yotta config
if(NOT YOTTA_CFG_NORDIC_SOFTDEVICE)
    set(YOTTA_CFG_NORDIC_SOFTDEVICE "S130")
endif()

# Set the image to NOT include bootloader if not defined through yotta config
if(NOT YOTTA_CFG_IMAGE_FOTA)
    set(YOTTA_CFG_IMAGE_FOTA FALSE)
endif()

# Set the heap warning threshold if not defined through yotta config
if(NOT YOTTA_CFG_IMAGE_HEAP_WARNING_THRESHOLD)
    set(YOTTA_CFG_IMAGE_HEAP_WARNING_THRESHOLD 1024)
endif()

# legacy definitions for building mbed 2.0 modules with a retrofitted build
# system:
set(MBED_LEGACY_TARGET_DEFINITIONS "NORDIC" "NRF51822_MKIT" "MCU_NRF51822" "MCU_NORDIC_${YOTTA_CFG_NRF51822_RAM_SIZE}")
# provide compatibility definitions for compiling with this target: these are
# definitions that legacy code assumes will be defined.
add_definitions("-DNRF51 -DTARGET_NORDIC -DTARGET_M0 -D__MBED__=1 -DMCU_NORDIC_${YOTTA_CFG_NRF51822_RAM_SIZE} -DTARGET_NRF51822 -DTARGET_MCU_NORDIC_${YOTTA_CFG_NRF51822_RAM_SIZE} -D__CORTEX_M0 -DARM_MATH_CM0")

if(YOTTA_CFG_NORDIC_SOFTDEVICE STREQUAL "S110")
    add_definitions("-DTARGET_MCU_NRF51_${YOTTA_CFG_NRF51822_RAM_SIZE} -DTARGET_MCU_NRF51_${YOTTA_CFG_NRF51822_RAM_SIZE}_S110")
    set(MBED_LEGACY_TARGET_DEFINITIONS   ${MBED_LEGACY_TARGET_DEFINITIONS} "MCU_NRF51" "MCU_NRF51_${YOTTA_CFG_NRF51822_RAM_SIZE}" "MCU_NORDIC_${YOTTA_CFG_NRF51822_RAM_SIZE}_S110")
    set(NRF51822_LINKER_FLAGS_FILE_PATH  "${CMAKE_CURRENT_LIST_DIR}/../ld/nRF51822_${YOTTA_CFG_NRF51822_RAM_SIZE}_S110.sct")
    set(NRF51822_SOFTDEVICE_FILE_PATH    "${CMAKE_CURRENT_LIST_DIR}/../softdevice/s110_nrf51822_8.0.0_softdevice.hex")
elseif(YOTTA_CFG_NORDIC_SOFTDEVICE STREQUAL "S130")
    set(NRF51822_LINKER_FLAGS_FILE_PATH  "${CMAKE_CURRENT_LIST_DIR}/../ld/nRF51822_${YOTTA_CFG_NRF51822_RAM_SIZE}_S130.sct")
    set(NRF51822_SOFTDEVICE_FILE_PATH    "${CMAKE_CURRENT_LIST_DIR}/../softdevice/s130_nrf51_1.0.0_softdevice.hex")
else()
    message(FATAL_ERROR "SoftDevice version '${YOTTA_CFG_NORDIC_SOFTDEVICE}' is not recognized. Please check your yotta config file.")
endif()

# append non-generic flags, and set NRF51822-specific link script
set(_CPU_COMPILATION_OPTIONS "--CPU=Cortex-M0 -D__thumb2__")

set(CMAKE_C_FLAGS_INIT          "${CMAKE_C_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_ASM_FLAGS_INIT        "${CMAKE_ASM_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_CXX_FLAGS_INIT        "${CMAKE_CXX_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${CMAKE_EXE_LINKER_FLAGS_INIT} --info=totals --list=.link_totals.txt --scatter ${NRF51822_LINKER_FLAGS_FILE_PATH}")

# used by the apply_target_rules function below:
set(NRF51822_SOFTDEVICE_HEX_FILE "${NRF51822_SOFTDEVICE_FILE_PATH}")
set(NRF51822_BOOTLOADER_HEX_FILE "${CMAKE_CURRENT_LIST_DIR}/../bootloader/s130_nrf51_1.0.0_bootloader.hex")
set(NRF51822_MERGE_HEX_SCRIPT    "${CMAKE_CURRENT_LIST_DIR}/../scripts/merge_hex.py")
set(NRF51822_MEMORY_INFO_SCRIPT  "${CMAKE_CURRENT_LIST_DIR}/../scripts/memory_info.py")

# define a function for yotta to apply target-specific rules to build products,
# in our case we need to convert the built elf file to .hex, and add the
# pre-built softdevice:
function(yotta_apply_target_rules target_type target_name)
    if(${target_type} STREQUAL "EXECUTABLE")
        if(YOTTA_CFG_IMAGE_FOTA)
            add_custom_command(TARGET ${target_name}
                POST_BUILD
                # fromelf to hex
                COMMAND fromelf --i32combined --output=${target_name}.hex ${target_name}
                # and append the softdevice hex file
                COMMAND python ${NRF51822_MERGE_HEX_SCRIPT} ${NRF51822_SOFTDEVICE_HEX_FILE} ${target_name}.hex ${target_name}-combined.hex
                # append the softdevice and bootloader hex file
                COMMAND python ${NRF51822_MERGE_HEX_SCRIPT} ${target_name}-combined.hex ${NRF51822_BOOTLOADER_HEX_FILE} ${target_name}-combined-fota.hex
                COMMENT "hexifying and adding softdevice and bootloader to ${target_name}"
                VERBATIM
            )
        else()
            add_custom_command(TARGET ${target_name}
                POST_BUILD
                # fromelf to hex
                COMMAND fromelf --i32combined --output=${target_name}.hex ${target_name}
                # and append the softdevice hex file
                COMMAND python ${NRF51822_MERGE_HEX_SCRIPT} ${NRF51822_SOFTDEVICE_HEX_FILE} ${target_name}.hex ${target_name}-combined.hex
                COMMENT "hexifying and adding softdevice to ${target_name}"
                VERBATIM
            )
        endif()
        add_custom_command(TARGET ${target_name}
            POST_BUILD
            # printing memory usage information
            COMMAND python ${NRF51822_MEMORY_INFO_SCRIPT} ${target_name} ${YOTTA_CFG_IMAGE_HEAP_WARNING_THRESHOLD}
            COMMENT "printing memory usage information"
            VERBATIM
        )
    endif()
endfunction()
