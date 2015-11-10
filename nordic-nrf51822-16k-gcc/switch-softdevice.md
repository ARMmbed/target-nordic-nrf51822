It is possible to use this target to build applications using the non-default
Nordic SoftDevice. To achieve this in an application that uses this target
simply add a `config.json` file within your module (refer to the
[yotta documentation](http://yottadocs.mbed.com/reference/config.html) for more
information). The `config.json` must contain the following JSON structure:

```
{
  "nordic": {
    "softdevice": "<Your_SoftDevice>"
  }
}
```

The currently supported SoftDevices are:

* S110
* S130 (default)

When building, yotta will read this configuration file and define
`YOTTA_CFG_NORDIC_SOFTDEVICE`. This definition is used by the
`toolchain.cmake` script to  add additional compilation flags (if necessary)
and to select the correct linker script and SoftDevice binary. If
`YOTTA_CFG_NORDIC_SOFTDEVICE` is not defined, then the application will be
built with the default SoftDevice (S130). Finally, attempting to build with an
unsupported SoftDevice version will result in an error and the build process
will abort.

