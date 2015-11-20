This folder contains the following python scripts that are used during the
post build stage (see `<root_folder>/CMake/toolchain.cmake`):

* `memory_info.py`: A simple script that takes an ELF executable and an integer
as command line arguments and outputs a short summary of the memory usage of
the application in bytes. Furthermore, it prints warnings if the size of the
heap falls below the supplied integer.
* `merge_hex.py`: A script that takes two `.hex` files as command line arguments
and merges them into a single `.hex` file.
