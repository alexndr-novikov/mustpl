#!/usr/bin/make

CC = gcc
TARGET = mustpl
LDFLAGS = -std=gnu99 -s -static -Wall -Werror -Wl,--build-id=none
CFLAGS = -std=gnu99 -c -fPIC -Wall -Wextra -g -Os
version ?= 0.0.0-undefined

.PHONY: all src/version.h $(TARGET) clean
all: $(TARGET)

$(TARGET): obj/cjson.o obj/mustach-cjson.o obj/mustach-wrap.o obj/mustach.o obj/envsubst.o obj/cli.o obj/main.o
	$(CC) $(LDFLAGS) -o $(TARGET) $(wildcard obj/*.o)
	@file $(TARGET) # print file info

src/version.h:
	@printf '// Code generated by `make version.h`; DO NOT EDIT.\n\n#define APP_VERSION "%s"\n' "$(version)" > $@

obj/envsubst.o: src/envsubst.c
	$(CC) $(CFLAGS) -o $@ $<

obj/cli.o: src/cli.c src/version.h
	$(CC) $(CFLAGS) -o $@ $<

obj/main.o: src/main.c
	$(CC) $(CFLAGS) -o $@ $<

obj/cjson.o: libs/cjson/cJSON.c
	$(CC) $(CFLAGS) -o $@ $<

obj/mustach.o: libs/mustach/mustach.c
	$(CC) $(CFLAGS) -o $@ $<

obj/mustach-wrap.o: libs/mustach/mustach-wrap.c
	$(CC) $(CFLAGS) -o $@ $<

obj/mustach-cjson.o: libs/mustach/mustach-cjson.c
	$(CC) $(CFLAGS) -o $@ $<

test: ## Run tests
	@set -e; for n in $(wildcard tests/*); do \
		$(MAKE) -C $$n test clean; \
	done

clean: ## Cleaning
	-rm $(TARGET) src/version.h obj/*.o
