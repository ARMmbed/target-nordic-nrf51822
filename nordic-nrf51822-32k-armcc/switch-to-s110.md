It is possible to use this target to build applications that use the Nordic
SoftDevice 110 (S110) rather than the default SoftDevice 130 (S130). To achieve
this in an application that uses this target simply add a `config.json`
file within your module (refer to the [yotta documentation](http://yottadocs.mbed.com/reference/config.html) for more
information). The `config.json` must contain the following JSON structure:

```
{
  "nordic": {
    "softdevice_s110": true
  }
}
```

When building, yotta will read this configuration file and define
`YOTTA_CFG_NORDIC_SOFTDEVICE_S110`. This definition is used by the
`toolchain.cmake` script to  add additional compilation flags and to select
the correct linker script and SoftDevice binary. To switch back to S130 remove
the `config.json` file and remove previous build data by running `yotta clean`.

