#!/usr/bin/env python

"""This script will merge two hex files and write the output to a hex file.
   USAGE: merge_hex.py input_file1 input_file2 output_file.
"""

import sys

def main(arguments):
    try:
        from intelhex import IntelHex
    except:
        fail_color = '\033[91m'
        print(fail_color + 'error: You do not have \'intelhex\' installed. Please run \'pip install intelhex\' then retry.')
        return 1

    if not len(arguments) == 3:
        print(fail_color + 'error: Improper use of merge_hex.py.')
	print(fail_color + 'USAGE: merge_hex.py input_file1 input_file2 output_file.')
        return 1

    orig = IntelHex(arguments[0])
    new = IntelHex(arguments[1])
    orig.merge(new, overlap='replace')
    orig.write_hex_file(arguments[2])

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
