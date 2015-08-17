#!/usr/bin/env python

"""This script will merge two hex files and write the output to a hex file
   USAGE: merge_hex.py input_file1 input_file2 output_file
"""

import sys
from intelhex import IntelHex

def main(arguments):
    if not len(arguments) == 3:
        return 1

    orig = IntelHex(arguments[0])
    new = IntelHex(arguments[1])
    orig.merge(new, overlap='replace')
    orig.write_hex_file(arguments[2])

if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
