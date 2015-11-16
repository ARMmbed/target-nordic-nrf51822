#! /usr/bin/env python

"""This script reads the map file generated after the build process and prints
   memory layout information of an nRF51 application.
   USAGE: mem_report.py exec_filepath
"""

import sys
import os.path
import re
import subprocess
from distutils import spawn

WARNING_THRESHOLD = 1024
ARM_SIZE_UTILITY  = 'arm-none-eabi-size'

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
                     re.compile(generic_pattern.format('RW_IRAM1')), re.compile(generic_pattern.format('RW_IRAM1')),
                     re.compile(generic_pattern.format('ARM_LIB_HEAP')), re.compile(generic_pattern.format('ARM_LIB_STACK'))]

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
    if len(arguments) != 1:
        return fail('Improper use of mem_report.py.\nUSAGE: mem_report.py exec_filepath')
    exec_filepath = arguments[0]

    # Test if required utility exists
    if not spawn.find_executable(ARM_SIZE_UTILITY):
        print(warning('\'{0}\' could not be found. No memory usage information will be reported.'.format(ARM_SIZE_UTILITY)))
        return 0

    # Execute arm-none-eabi-size and get output
    process = subprocess.Popen([ARM_SIZE_UTILITY, '-A', exec_filepath], stdout=subprocess.PIPE)
    stdout  = process.communicate()[0].strip()

    # Process output to remove memory addresses and print warnings when heap is low
    warnings_list = []
    print('Memory usage for \'{0}\''.format(exec_filepath))
    for line in stdout.split(os.linesep):
        for index, pattern in enumerate(compiled_patterns):
            match = re.match(pattern, line)
            if match:
                print(match.group('useful_info'))
                if match.group('section') == 'heap' and WARNING_THRESHOLD > int(match.group('size')):
                    warnings_list.append(warning('Available heap < {0} bytes'.format(WARNING_THRESHOLD)))
                break
    print(os.linesep.join(warnings_list))

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
