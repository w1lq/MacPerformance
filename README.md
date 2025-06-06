# MacPerformance

This repository contains scripts and simulation files for evaluating MAC performance.

## Running tests

Perl tests are located in the `t/` directory and can be executed with `prove`:

```sh
prove -lv t/get_packet_data.t
```

This checks that `getPacketData` correctly filters ghost node data from packet logs.
