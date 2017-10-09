CC=gcc
lj_libs=../../../work/luajit/lib
lj_inc=../../../work/luajit/include/luajit-2.0
target_dir=../


CFLAGS=-std=c99 -Wall -fPIC -shared -I$(lj_inc)
LDFLAGS=-L$(lj_libs)
# LIBS=-lluajit

all: libsum.so

help:
	@echo "make [test|all|libsum.so|clean]"

test:
	@echo "CFLAGS:$(CFLAGS)", "LDFLAGS:$(LDFLAGS)"


libsum.so: sum.c
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

install:libsum.so
	cp libsum.so "$(target_dir)/"

clean:
	rm -rf *.o *.so
