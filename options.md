This document describes the yotta config options that can be used to customise
the build process when using the `nordic-nrf51822-gcc` and
`nordic-nrf51822-armcc` targets. For more information on the yotta config
section refer to the [yotta documentation](http://yottadocs.mbed.com/reference/config.html).

Set the target RAM size
-----------------------

The nRF51-based devices come in two flavours: 16KB (e.g. mkit and micro:bit)
and 32KB (e.g. nrf51dk). To produce the final image, the build process must be
aware of the amount of RAM available in the target. If you are using one of
the nRF51 child targets (`mkit-armcc`, `mkit-gcc`, `nrf51dk-gcc`,
`nrf51dk-armcc`, `bbc-microbit-gcc` or `bbc-microbit-armcc`) you do not need to
worry about this. However, if you are creating a target that inherits from
either `nordic-nrf51822-gcc` or `nordic-nrf51822-armcc` you *must* select the
target RAM available. If your targets RAM is 16KB then include the following
lines of JSON inside the config section of your `target.json`:

```
"chip": {
  "nrf51822": {
    "16k": true
  }
}
```

Alternatively, if the target has 32KB of available RAM then include the
following lines:

```
"chip": {
  "nrf51822": {
    "32k": true
  }
}
```

Using different SoftDevice versions
-----------------------------------

The SoftDevice is a precompiled binary from Nordic Semiconductor that
implements functionality used by some yotta modules. More information can be
found [here](https://www.nordicsemi.com/eng/Products/Bluetooth-Smart-Bluetooth-low-energy/nRF51822).

It is possible to use the `nordic-nrf51822-gcc` and `nordic-nrf51822-armcc`
targets to build applications using the non-default Nordic SoftDevice. To
achieve this in an application simply add a `config.json` file within your
module containing the following JSON structure:

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
`toolchain.cmake` scripts to  add additional compilation flags (if necessary)
and to select the correct linker script and SoftDevice binary. If
`YOTTA_CFG_NORDIC_SOFTDEVICE` is not defined, then the application will be
built with the default SoftDevice (S130). Finally, attempting to build with an
unsupported SoftDevice version will result in an error and the build process
will abort.

Change heap warning threshold
-----------------------------

When you build your application using `nordic-nrf51822-gcc` or
`nordic-nrf51822-armcc`, a memory usage summary will be printed at the end of
the build process. The idea behind this is to help you understand your
program's memory usage.

If the size of the heap falls below some threshold (default is 1024 bytes)
then a warning message will be printed alongside the memory summary. It is
possible to change the threshold value by simply adding the `config.json` file
within the application module containing the following JSON structure:

```
"image": {
  "heap": {
    "warning_threshold": 1024
  }
}
```

Build FOTA image
----------------

When you run `yotta build`, the default output includes and ELF file, your
application's hex file and a 'combined' hex that includes your application code
and the SoftDevice of your choice. If you also wish to include the bootloader
to enable FOTA then add the following lines inside your `config.json`:

```
"image": {
  "fota": false
}
```

When the build process has concluded the FOTA-enabled image can be found in
`build/<target_name>/source/<module_name>-combined-fota.hex`.

