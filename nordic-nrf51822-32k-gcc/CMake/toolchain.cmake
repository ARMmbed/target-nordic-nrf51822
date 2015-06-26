# Copyright (C) 2014-2015 ARM Limited. All rights reserved. 

if(TARGET_NORDIC_NRF51822_GCC_TOOLCHAIN_INCLUDED)
    return()
endif()
set(TARGET_NORDIC_NRF51822_GCC_TOOLCHAIN_INCLUDED 1)

# provide compatibility definitions for compiling with this target: these are
# definitions that legacy code assumes will be defined. Before adding something
# here, think VERY CAREFULLY if you can't change anywhere that relies on the
# definition that you're about to add to rely on the TARGET_LIKE_XXX
# definitions that yotta provides based on the target.json file.
#
set(YOTTA_TARGET_DEFINITIONS "-DMCU_NORDIC_32K -DTARGET_NRF51822 -DTOOLCHAIN_GCC -DTOOLCHAIN_GCC_ARM -DMBED_OPERATORS")

# append non-generic flags, and set NRF51822-specific link script

set(_CPU_COMPILATION_OPTIONS "-mcpu=cortex-m0 -mthumb -D__thumb2__")

set(CMAKE_C_FLAGS_INIT             "${CMAKE_C_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_ASM_FLAGS_INIT           "${CMAKE_ASM_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_CXX_FLAGS_INIT           "${CMAKE_CXX_FLAGS_INIT} ${_CPU_COMPILATION_OPTIONS}")
set(CMAKE_MODULE_LINKER_FLAGS_INIT "${CMAKE_MODULE_LINKER_FLAGS_INIT} -mcpu=cortex-m0 -mthumb")
set(CMAKE_EXE_LINKER_FLAGS_INIT    "${CMAKE_EXE_LINKER_FLAGS_INIT} -mcpu=cortex-m0 -mthumb -T${CMAKE_CURRENT_LIST_DIR}/../ld/NRF51822.ld") 

# post-process elf files into .bin files:
# TODO: merge hex files here 
#set(YOTTA_POSTPROCESS_COMMAND "arm-none-eabi-objcopy -O binary YOTTA_CURRENT_EXE_NAME YOTTA_CURRENT_EXE_NAME.bin")

