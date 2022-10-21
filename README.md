# help me

gdb can only do so much

If you're on linux, this is the script I use to run it
```sh
#!/bin/sh
make -s || exit
cd build

if [ "$1" = "d" ]; then
    qemu-riscv64 -g 1234 main &
    riscv64-linux-gnu-gdb -q \
        -ex "target remote :1234" \
        main
else
    qemu-riscv64 main
fi
```

As you can see, you need `qemu-riscv64` and `riscv64-linux-gnu-...`, I personally got both from my package manager.

If you're not on linux, good luck

