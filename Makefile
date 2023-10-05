# Copyright Joyent, Inc. and other Node contributors. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

HELPER ?=
BINEXT ?=

CC?=gcc
AR?=ar

CPPFLAGS ?=
LDFLAGS ?=

CPPFLAGS += -I.
CPPFLAGS_DEBUG = $(CPPFLAGS) -DHTTP_PARSER_STRICT=1
CPPFLAGS_DEBUG += $(CPPFLAGS_DEBUG_EXTRA)
CPPFLAGS_FAST = $(CPPFLAGS) -DHTTP_PARSER_STRICT=0
CPPFLAGS_FAST += $(CPPFLAGS_FAST_EXTRA)
CPPFLAGS_BENCH = $(CPPFLAGS_FAST)

CFLAGS += -Wall -Wextra -Werror
CFLAGS_DEBUG = $(CFLAGS) -O0 -g $(CFLAGS_DEBUG_EXTRA)
CFLAGS_FAST = $(CFLAGS) -O3 $(CFLAGS_FAST_EXTRA)

test: test_g test_fast
	$(HELPER) ./test_g$(BINEXT)
	$(HELPER) ./test_fast$(BINEXT)

test_g: url_parser_g.o test_g.o
	$(CC) $(CFLAGS_DEBUG) $(LDFLAGS) url_parser_g.o test_g.o -o $@

test_g.o: test.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_DEBUG) $(CFLAGS_DEBUG) -c test.c -o $@

url_parser_g.o: url_parser.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_DEBUG) $(CFLAGS_DEBUG) -c url_parser.c -o $@

test_fast: url_parser.o test.o url_parser.h
	$(CC) $(CFLAGS_FAST) $(LDFLAGS) url_parser.o test.o -o $@

test.o: test.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_FAST) -c test.c -o $@

url_parser.o: url_parser.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_FAST) -c url_parser.c

test-valgrind: test_g
	valgrind ./test_g

url_parser: url_parser.o url_parser_demo.c
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_FAST) $^ -o $@

url_parser_g: url_parser_g.o url_parser_demo.c
	$(CC) $(CPPFLAGS_DEBUG) $(CFLAGS_DEBUG) $^ -o $@

clean:
	rm -f *.o *.a tags test test_fast test_g \
		*.exe *.exe.so

url_parser_demo.c: url_parser.h

.PHONY: clean test test-valgrind
