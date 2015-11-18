#! /usr/bin/env python

"""This script reads the map file generated after the build process and prints
   memory layout information of an nRF51 application.
   USAGE: memory_info.py exec_filepath heap_warning_threshold
"""

import sys
import os.path
import re
import subprocess
from distutils import spawn

ARM_SIZE_UTILITY  = 'arm-none-eabi-size'
HEAP_SYMBOL       = 'ARM_LIB_HEAP'
STACK_SYMBOL      = 'ARM_LIB_STACK'
BSS_SYMBOL        = 'RW_IRAM1'
DATA_SYMBOL       = 'RW_IRAM1'

fail_color    = ''
warning_color = ''

# If colorama is present, set the fail color to red
try:
    from colorama import init, deinit, Fore
    fail_color    = Fore.RED
    warning_color = Fore.BLUE
except:
    pass

generic_pattern   = '^(?P<useful_info>(?P<section>{0})\\s+(?P<size>\\d+))\\s+\\d+$'
compiled_patterns = [re.compile('^(?P<useful_info>(?P<section>section)\\s+size)\\s+addr$'),
                     re.compile(generic_pattern.format(DATA_SYMBOL)), re.compile(generic_pattern.format(BSS_SYMBOL)),
                     re.compile(generic_pattern.format(HEAP_SYMBOL)), re.compile(generic_pattern.format(STACK_SYMBOL))]

def fail(message):
    print(fail_color + 'ERROR: ' + message)

    # If we've included ANSI color in output, reset the output style
    if fail_color:
        print(Fore.RESET)
        deinit()

    return 1

def warning(message):
    output = warning_color + 'WARNING: ' + message

    # If we've included ANSI color in output, reset the output style
    if warning_color:
        output += Fore.RESET
        deinit()

    return output

def main(arguments):
    # If using ANSI coloring is available, initialize colorama
    if fail_color and warning_color:
        init()

    # Ensure the right number of arguments are supplied
    if len(arguments) != 2:
        return fail('Improper use of memory_info.py.\nUSAGE: memory_info.py exec_filepath heap_warning_threshold.')
    exec_filepath     = arguments[0]
    warning_threshold = 0
    try:
        warning_threshold = int(arguments[1])
        if warning_threshold < 0:
            return fail('Second argument of memory_info.py must be a positive integer. Found \'{0}\'.'.format(arguments[1]))
    except ValueError:
        return fail('Second argument of memory_info.py must be a positive integer. Found \'{0}\'.'.format(arguments[1]))

    # Test if required utility exists
    if not spawn.find_executable(ARM_SIZE_UTILITY):
        print(warning('\'{0}\' could not be found. No memory usage information will be reported.'.format(ARM_SIZE_UTILITY)))
        return 0

    # Execute arm-none-eabi-size and get output
    process = subprocess.Popen([ARM_SIZE_UTILITY, '-A', exec_filepath], stdout=subprocess.PIPE)
    input   = process.communicate()[0].strip()

    # Process output to remove memory addresses and print warnings when heap is low
    warnings_list = []
    print('Memory usage for \'{0}\''.format(exec_filepath))
    for line in input.split(os.linesep):
        for index, pattern in enumerate(compiled_patterns):
            match = re.match(pattern, line)
            if match:
                print(match.group('useful_info'))
                if match.group('section') == HEAP_SYMBOL and warning_threshold > int(match.group('size')):
                    warnings_list.append(warning('Available heap < {0} bytes.'.format(warning_threshold)))
                break
    print(os.linesep.join(warnings_list))

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
