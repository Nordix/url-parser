URL Parser
==========

This URL parser was extracted from [http-parser](https://github.com/nodejs/http-parser),
which is no longer actively maitained. It was previouly used by NodeJS.

It is a simplistic zero-copy URL parser designed for performance.
It does not make any syscalls nor allocations.
It can be interrupted at anytime.
It has no dependencies.

Usage
-----

```C
/* Initialize all http_parser_url members to 0 */
void http_parser_url_init(struct http_parser_url *u);

/* Parse a URL; return nonzero on failure */
int http_parser_parse_url(const char *buf, size_t buflen,
                          int is_connect,
                          struct http_parser_url *u);
```

See [`url_parser.h`](url_parser.h) for details.

There is a demo program included. Build it with `make url_parser`.
Run the tests with `make test`.
