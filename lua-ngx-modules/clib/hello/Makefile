CC=gcc
lj_libs=../../../work/luajit/lib
lj_inc=../../../work/luajit/include/luajit-2.0
target_dir=../


CFLAGS=-Wall -fPIC -shared -I$(lj_inc)
LDFLAGS=-L$(lj_libs)
# LIBS=-lluajit

all: libhello.so

help:
	@echo "make [test|all|libhello.so|clean]"

test:
	@echo "CFLAGS:$(CFLAGS)", "LDFLAGS:$(LDFLAGS)"


libhello.so: hello.c
	$(CC) -o $@ $^ $(CFLAGS) $(LDFLAGS)

install:libhello.so
	cp libhello.so "$(target_dir)/"

clean:
	rm -rf *.o *.so
