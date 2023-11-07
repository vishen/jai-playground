# JSON Parser

A simple toy JSON parser to play around with Jai. 

## Example

```
$ jai-macos first.jai - debug  && ./first

We were compiled with: ["debug"]
json data: {
	"key1": "value1",
	"key2": [1, "2", 3.0, true, false, null],
	"key3": { "key3_1": { "key3_1_1": "abcdef", "key3_1_2": 123} },
}


{OPEN_OBJECT, "", 1, 0}
{KEY, "key1", 2, 6}
{COLON, "", 2, 7}
{STRING, "value1", 2, 16}
{COMMA, "", 2, 17}
{STRING, "key2", 3, 6}
{COLON, "", 3, 7}
{OPEN_LIST, "", 3, 9}
{NUMBER, "1", 3, 11}
{STRING, "2", 3, 15}
{COMMA, "", 3, 16}
{NUMBER, "3.0", 3, 21}
{TRUE, "", 3, 23}
{COMMA, "", 3, 27}
{FALSE, "", 3, 29}
{COMMA, "", 3, 34}
{NULL, "", 3, 36}
{CLOSE_LIST, "", 3, 40}
{COMMA, "", 3, 41}
{STRING, "key3", 4, 6}
{COLON, "", 4, 7}
{OPEN_OBJECT, "", 4, 9}
{KEY, "key3_1", 4, 18}
{COLON, "", 4, 19}
{OPEN_OBJECT, "", 4, 21}
{KEY, "key3_1_1", 4, 32}
{COLON, "", 4, 33}
{STRING, "abcdef", 4, 42}
{COMMA, "", 4, 43}
{STRING, "key3_1_2", 4, 54}
{COLON, "", 4, 55}
{NUMBER, "123", 4, 60}
{CLOSE_OBJECT, "", 4, 62}
{COMMA, "", 4, 63}
{CLOSE_OBJECT, "", 5, 0}

Total: 0 bytes in 0 allocations.

Marked as non-leaks: 0 bytes in 0 allocations.
```
