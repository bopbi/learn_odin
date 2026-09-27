# Learn Odin — a curriculum for a Kotlin/Java developer

You already know how to program, and (if you did `back_to_c`) you already survived
manual memory in C. Odin is the next step: a modern C-replacement — compiled to
machine code, no GC, no runtime — but with the ergonomics a JVM developer misses:
defer, multiple return values, tagged unions, slices, and a real standard library.

The capstone is a **simple HTTP server** — deliberately the same shape as the
`back_to_c` capstone, so you can compare the two implementations side by side and
see exactly what Odin fixes (and what it deliberately doesn't).

## Why an HTTP server and not a game?

Odin's showcases are mostly games and visualizations (it ships `vendor:raylib`,
`vendor:sdl3`, etc.), and games are where the language community lives. But as a
*first* project an HTTP server exercises the skills you'll use every day — string
parsing, memory ownership, error handling, file I/O, sockets — and you already
know the domain from the C version, so all your attention goes to the language.
Module 10 is an optional raylib detour for the showcase flavor afterwards.

## How to use this

1. Read the modules in order (`00` → `09`; `10` is optional).
2. Do every exercise in `exercises/` (one folder per exercise, e.g.
   `exercises/01-fizzbuzz/`). Typing the code *is* the learning — don't copy-paste.
3. Run programs with:

   ```
   odin run .
   ```

   Check before/instead of running — it type-checks without producing a binary:

   ```
   odin check . -vet
   ```

4. Odin's error messages are genuinely good. Read them before asking for help.
5. The standard library source is your best documentation:

   ```
   odin root        # prints the install dir; browse core/ from there
   ```

6. A reference HTTP server lives in `capstone/http-server/`. Build your own first
   (module 09), then compare — and then compare *that* with your C version from
   `back_to_c`.

## Mindset shifts (JVM → Odin)

| JVM instinct | Odin reality |
|---|---|
| Garbage collector frees memory | You free what you allocate — but `defer` and allocator swapping make it disciplined, not painful |
| `val` vs `var` | No immutability for locals: `x := 5` is always mutable; `X :: 5` is a compile-time constant |
| Exceptions unwind the stack | Multiple return values: `value, err := thing()`; `or_return` propagates like `?` in Rust |
| Nullability in the type system (`String?`) | Pointers can be `nil`, but the idiom is `Maybe(T)` (a tagged union) or a `(T, bool)` pair |
| `sealed class` hierarchies | Tagged `union` + `switch` — exhaustive, no inheritance anywhere in the language |
| Interfaces / lambdas | Procedure values (`proc` is a first-class type) and procedure-group overloading |
| Classes with methods | Plain `struct`s; behavior lives in procedures that take the struct as a parameter |
| Strings are objects with methods | `string` is an immutable `[]u8` view (pointer + length); operations live in `core:strings` |
| Gradle builds and fetches dependencies | `odin build .`; the `core:` and `vendor:` collections ship with the compiler — no package manager |
| The JVM JIT-compiles at runtime | The compiler emits machine code up front — the binary *is* the product |
| Coroutines hide the call stack | No hidden machinery: `defer`, explicit allocators, and `context` make the invisible visible |

## Modules

| # | Module | You learn | Capstone skill it feeds |
|---|--------|-----------|-------------------------|
| 00 | Setup | `odin run`/`check`/`vet`, browsing `core:` | toolchain |
| 01 | First program | `package`, `main`, `:=` vs `::`, types, `fmt`, `os.args` | parsing the port argument |
| 02 | Procedures & packages | `proc`, multiple returns, overloading, imports | organizing the server |
| 03 | Pointers & memory | `^T`, `new`/`delete`, allocators, `defer`, leak tracking | connection buffers, cleanup |
| 04 | Arrays, slices & strings | `[N]T`, `[]T`, `[dynamic]T`, `core:strings` | parsing HTTP requests |
| 05 | Structs, enums & unions | tagged unions, `bit_set`, no classes | request/response types, method enum |
| 06 | Errors & files | `or_return`, `or_else`, `os.Error`, file I/O | serving files, 404s |
| 07 | Context, maps & JSON | `context.allocator`, `map`, `core:encoding/json` | headers, JSON responses |
| 08 | Sockets | `core:net`: TCP listen/accept/recv/send | the server itself |
| 09 | Capstone | HTTP protocol, milestones | ship it |
| 10 | Bonus: raylib | `vendor:raylib`, a window and a moving square | the "showcase" flavor |

## Resources

- <https://odin-lang.org/docs/overview/> — the official overview; read it alongside module 01–05.
- `odin root` + `core/` source — the stdlib is readable Odin; reading it *is* the docs.
- <https://pkg.odin-lang.org/core/> — browsable stdlib documentation.
- <https://odin-lang.org/> — news and showcase (see what people build with it).
- Discord (`#help` on the Odin server) — the community is small and responsive.

Next: [Module 00 — Setup](00-setup.md)
