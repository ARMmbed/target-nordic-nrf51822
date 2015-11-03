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

if(TARGET_NORDIC_NRF51822_16K_ARMCC_TOOLCHAIN_INCLUDED)
    return()
endif()
set(TARGET_NORDIC_NRF51822_16K_ARMCC_TOOLCHAIN_INCLUDED 1)

# legacy definitions for building mbed 2.0 modules with a retrofitted build
# system:
set(MBED_LEGACY_TARGET_DEFINITIONS "NORDIC" "NRF51822_MKIT" "MCU_NRF51822" "MCU_NORDIC_16K")
if(YOTTA_CFG_NORDIC_SOFTDEVICE_S110)
    set(MBED_LEGACY_TARGET_DEFINITIONS   ${MBED_LEGACY_TARGET_DEFINITIONS} "MCU_NRF51" "MCU_NRF51_16K" "MCU_NORDIC_16K_S110")
    set(NRF51822_LINKER_FLAGS_FILE_PATH  "${CMAKE_CURRENT_LIST_DIR}/../ld/nRF51822_S110.sct")
    set(NRF51822_SOFTDEVICE_FILE_PATH    "${CMAKE_CURRENT_LIST_DIR}/../softdevice/s110_nrf51822_8.0.0_softdevice.hex")
else()
    set(NRF51822_LINKER_FLAGS_FILE_PATH  "${CMAKE_CURRENT_LIST_DIR}/../ld/nRF51822_S130.sct")
    set(NRF51822_SOFTDEVICE_FILE_PATH    "${CMAKE_CURRENT_LIST_DIR}/../softdevice/s130_nrf51_1.0.0_softdevice.hex")
endif()

# provide compatibility definitions for compiling with this target: these are
# definitions that legacy code assumes will be defined.
add_definitions("-DNRF51 -DTARGET_NORDIC -DTARGET_M0 -D__MBED__=1 -DMCU_NORDIC_16K -DTARGET_NRF51822 -DTARGET_MCU_NORDIC_16K -D__CORTEX_M0 -DARM_MATH_CM0")
if(YOTTA_CFG_NORDIC_SOFTDEVICE_S110)
    add_definitions("-DTARGET_MCU_NRF51_16K -DTARGET_MCU_NRF51_16K_S110")
endif()

# append non-generic flags, and set NRF51822-specific link script
set(_CPU_COMPILATION_OPTIONS "--CPU=Cortex-M0 -D__thumb2__")

set(CMAKE_C_FLAGS_INIT             "${CMAKE_C_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_ASM_FLAGS_INIT           "${CMAKE_ASM_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_CXX_FLAGS_INIT           "${CMAKE_CXX_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
#set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_MODULE_LINKER_FLAGS_INIT}")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} --info=totals --list=.link_totals.txt --scatter ${NRF51822_LINKER_FLAGS_FILE_PATH}")

# used by the apply_target_rules function below:
set(NRF51822_SOFTDEVICE_HEX_FILE "${NRF51822_SOFTDEVICE_FILE_PATH}")
set(NRF51822_MERGE_HEX_SCRIPT    "${CMAKE_CURRENT_LIST_DIR}/../scripts/merge_hex.py")

# define a function for yotta to apply target-specific rules to build products,
# in our case we need to convert the built elf file to .hex, and add the
# pre-built softdevice:
function(yotta_apply_target_rules target_type target_name)
    if(${target_type} STREQUAL "EXECUTABLE")
        add_custom_command(TARGET ${target_name}
            POST_BUILD
            COMMAND arm-none-eabi-size ${target_name}
            # fromelf to hex
            COMMAND fromelf --i32combined --output=${target_name}.hex ${target_name}
            # and append the softdevice hex file
            COMMAND python ${NRF51822_MERGE_HEX_SCRIPT} ${NRF51822_SOFTDEVICE_HEX_FILE} ${target_name}.hex ${target_name}-combined.hex
            COMMENT "hexifying and adding softdevice to ${target_name}"
            VERBATIM
        )
    endif()
endfunction()
