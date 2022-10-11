CC = riscv64-linux-gnu-gcc
GCC_ARGS = -static -g -nostdlib
SOURCES = $(wildcard src/*.s src/**/*.s)

build/main: $(SOURCES)
	$(CC) $(GCC_ARGS) -o build/main $(SOURCES)

clean:
	rm -r build/*
