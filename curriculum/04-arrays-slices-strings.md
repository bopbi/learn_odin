# Module 04 — Arrays, Slices & Strings

**Goal:** master Odin's three sequence types and the `string` type — the raw
material of HTTP request parsing.
**Time:** ~3 hours

## Three types, not one

Kotlin gives you `Array<T>` and `List<T>` and mostly hides the difference. Odin
makes you choose, and each choice is explicit about who owns the memory:

```odin
fixed: [5]int            // value type, lives inline (stack or inside a struct) — like C's int[5]
view:  []int             // slice: pointer+len VIEW into memory owned elsewhere — like a subList
grow:  [dynamic]int      // dynamic array: owns its buffer, append grows it — like ArrayList
```

| Kotlin | Odin | Ownership |
|---|---|---|
| `IntArray(5)` | `[5]int` | inline, copied on assignment |
| `List<Int>` (read view) | `[]int` | borrowed view; freeing is the owner's job |
| `ArrayList<Int>` | `[dynamic]int` | owns the buffer; `delete` it |

```odin
arr: [5]int = {1, 2, 3, 4, 5}
s := arr[1:4]            // []int view of elements 1..3 — no copy, no allocation
s[0] = 99                // arr[1] is now 99: slices share memory
fmt.println(len(s))      // 3 — len() is built-in, not a method

d := make([dynamic]int)  // like ArrayList()
defer delete(d)
append(&d, 1)
append(&d, 2, 3)
fmt.println(d, cap(d))   // cap = capacity of the backing buffer
```

- Slicing syntax `a[lo:hi]` is half-open, like Kotlin's `subList(lo, hi)` — but
  it's O(1) and aliases the same memory.
- Bounds are checked at runtime (panics, not UB — unlike C). Disable with
  `-no-bounds-check` only when you mean it.
- `for x in d`, `for x, i in d` iterate any of the three kinds.

## Strings are slices of bytes

```odin
s: string = "hello"      // immutable []u8: pointer + length, NOT NUL-terminated
fmt.println(len(s))      // 5 — O(1), unlike C's strlen
fmt.println(s[1:4])      // "ell" — slicing a string is free
```

Coming from Kotlin/JVM:

- A `string` is a **view**, not an object. `"hello"` points into the binary's
  read-only data; `s[1:4]` points into the middle of it. No allocation anywhere.
- Immutability is a *convention the compiler enforces on literals*: you cannot
  write through a `string`. To build one, use `[]byte` or `strings.Builder`,
  then convert.
- Not NUL-terminated — length is explicit. C interop uses the separate `cstring`
  type (`strings.clone_to_cstring` converts). If you did `back_to_c`, enjoy never
  writing `'\0'` again.
- `==` compares **contents** (`"a" + "b" == "ab"`… well, almost — see below:
  `+` doesn't concatenate; use `strings.concatenate` or a builder). No
  `equals()` trap: `==` just works.

## core:strings — your new String methods

Since strings have no methods, the library is a package of procs:

```odin
import "core:strings"

strings.has_prefix(line, "GET ")       // startsWith
strings.trim_space(raw)                 // trim — returns a sub-slice, no allocation
parts, _ := strings.split(line, " ")   // split — allocates the []string
defer delete(parts)

b := strings.builder_make()            // StringBuilder
defer strings.builder_destroy(&b)
strings.write_string(&b, "HTTP/1.1 ")
strings.write_string(&b, "200 OK")
response := strings.to_string(b)       // finalize to an immutable string
```

Rule of thumb for the capstone: **trim/slice/compare are free (views);
split/clone/concatenate allocate (delete them).** The doc comment on each proc
in `core/strings/strings.odin` says which.

## UTF-8

A `string` is UTF-8 bytes; indexing gives you bytes, not chars. Iterate `runes`
(Unicode code points, like Kotlin's `Char` at the code-point level):

```odin
for r in "héllo" {          // r is a rune (i32)
	fmt.println(r)
}
```

HTTP headers are ASCII — byte-level thinking is fine for the capstone.

## Exercises

In `exercises/04-*/`:

1. **word count** — read a file with `os.read_entire_file`, split into lines
   (`strings.split_lines`), split each into words (`strings.fields`), print
   line/word/rune counts like `wc`. Track every allocation; zero leaks.
2. **request line parser** — given `"GET /index.html HTTP/1.1"`, write
   `parse_request_line :: proc(line: string) -> (method, path, version: string,
   ok: bool)` using slicing/`strings.split`. The returned strings must be
   **views into the input** (no allocation) — that's the point of the exercise.
3. **header builder** — build a full `"HTTP/1.1 200 OK\r\nContent-Length:
   42\r\n\r\n"` response with `strings.builder_make`, using `fmt.sbprintf(&b,
   ...)` for the number. Compare its ergonomics with string concatenation in
   Kotlin — where did the allocations go?

## Self-check

- [ ] You can say who owns the memory for `[5]int`, `[]int`, and `[dynamic]int`
- [ ] You know why `s[1:4]` on a string allocates nothing
- [ ] You reach for `strings.*` procs instead of wishing for methods
- [ ] Your parser returns views, and you can explain why that's fast *and* safe
  (the input buffer outlives the views)

Next: [Module 05 — Structs, Enums & Unions](05-structs-enums-unions.md)
