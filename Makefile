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

BUILDDIR ?= $(CURDIR)
SOLIBNAME = liburl_parser
SOMAJOR = 1
SOMINOR = 0
SOREV   = 0
SOEXT ?= so
SONAME ?= $(SOLIBNAME).$(SOEXT).$(SOMAJOR).$(SOMINOR)
LIBNAME ?= $(SOLIBNAME).$(SOEXT).$(SOMAJOR).$(SOMINOR).$(SOREV)

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
CFLAGS_LIB = $(CFLAGS_FAST) -fPIC

LDFLAGS_LIB = $(LDFLAGS) -shared -Wl,-soname,$(SONAME)

INSTALL ?= install
PREFIX ?= /usr/local
LIBDIR = $(PREFIX)/lib
INCLUDEDIR = $(PREFIX)/include

all: library

test: $(BUILDDIR)/test_g $(BUILDDIR)/test_fast
	$(BUILDDIR)/test_g
	$(BUILDDIR)/test_fast

$(BUILDDIR)/test_g: $(BUILDDIR)/url_parser_g.o $(BUILDDIR)/test_g.o
	$(CC) $(CFLAGS_DEBUG) $(LDFLAGS) $(BUILDDIR)/url_parser_g.o $(BUILDDIR)/test_g.o -o $@

$(BUILDDIR)/test_g.o: test.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_DEBUG) $(CFLAGS_DEBUG) -c test.c -o $@

$(BUILDDIR)/url_parser_g.o: url_parser.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_DEBUG) $(CFLAGS_DEBUG) -c url_parser.c -o $@

$(BUILDDIR)/test_fast: $(BUILDDIR)/url_parser.o $(BUILDDIR)/test.o url_parser.h
	$(CC) $(CFLAGS_FAST) $(LDFLAGS) $(BUILDDIR)/url_parser.o $(BUILDDIR)/test.o -o $@

$(BUILDDIR)/test.o: test.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_FAST) -c test.c -o $@

$(BUILDDIR)/url_parser.o: url_parser.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_FAST) -c url_parser.c -o $@

test-valgrind: test_g
	valgrind ./test_g

$(BUILDDIR)/liburl_parser.o: url_parser.c url_parser.h Makefile
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_LIB) -c url_parser.c -o $@

library: $(BUILDDIR)/$(LIBNAME)

$(BUILDDIR)/$(LIBNAME): $(BUILDDIR)/liburl_parser.o
	$(CC) $(LDFLAGS_LIB) -o $@ $<

package: $(BUILDDIR)/liburl_parser.a

$(BUILDDIR)/liburl_parser.a: $(BUILDDIR)/url_parser.o
	$(AR) rcs $@ $<

$(BUILDDIR)/url_parser: $(BUILDDIR)/url_parser.o url_parser_demo.c
	$(CC) $(CPPFLAGS_FAST) $(CFLAGS_FAST) $^ -o $@

$(BUILDDIR)/url_parser_g: $(BUILDDIR)/url_parser_g.o url_parser_demo.c
	$(CC) $(CPPFLAGS_DEBUG) $(CFLAGS_DEBUG) $^ -o $@

install: library package
	$(INSTALL) -D url_parser.h $(DESTDIR)$(INCLUDEDIR)/url_parser.h
	$(INSTALL) -D $(BUILDDIR)/liburl_parser.a $(DESTDIR)$(LIBDIR)/liburl_parser.a
	$(INSTALL) -D $(BUILDDIR)/$(LIBNAME) $(DESTDIR)$(LIBDIR)/$(LIBNAME)
	ln -sf $(LIBNAME) $(DESTDIR)$(LIBDIR)/$(SONAME)
	ln -sf $(LIBNAME) $(DESTDIR)$(LIBDIR)/$(SOLIBNAME).$(SOEXT)

install-strip: library package
	$(INSTALL) -D url_parser.h $(DESTDIR)$(INCLUDEDIR)/url_parser.h
	$(INSTALL) -D -s $(BUILDDIR)/liburl_parser.a $(DESTDIR)$(LIBDIR)/liburl_parser.a
	$(INSTALL) -D -s $(BUILDDIR)/$(LIBNAME) $(DESTDIR)$(LIBDIR)/$(LIBNAME)
	ln -sf $(LIBNAME) $(DESTDIR)$(LIBDIR)/$(SONAME)
	ln -sf $(LIBNAME) $(DESTDIR)$(LIBDIR)/$(SOLIBNAME).$(SOEXT)

uninstall:
	rm $(DESTDIR)$(INCLUDEDIR)/url_parser.h
	rm $(DESTDIR)$(LIBDIR)/$(SOLIBNAME).$(SOEXT)
	rm $(DESTDIR)$(LIBDIR)/$(SONAME)
	rm $(DESTDIR)$(LIBDIR)/$(LIBNAME)
	rm $(DESTDIR)$(LIBDIR)/liburl_parser.a

clean:
	rm -f $(BUILDDIR)/*.o $(BUILDDIR)/*.a $(BUILDDIR)/*.so \
		$(BUILDDIR)/test_fast $(BUILDDIR)/test_g \
		$(BUILDDIR)/url_parser $(BUILDDIR)/url_parser_g

url_parser_demo.c: url_parser.h

.PHONY: all library package install install-strip uninstall clean test test-valgrind
