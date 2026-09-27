# Module 01 — Your First Odin Program

**Goal:** write, run, and check small Odin programs; understand the declaration
syntax and the type system basics.
**Time:** ~2–3 hours

## The big mental shift

```
Kotlin: .kt   → kotlinc → bytecode → JVM (JIT) → runs, with a runtime watching over you
C:      .c    → clang   → machine code         → runs directly on the CPU, nothing else
Odin:   .odin → odin    → machine code         → runs directly on the CPU, tiny runtime
```

Like C, there is no VM and no garbage collector. Unlike C, there *is* a small
runtime (it powers allocators and `context` — module 03/07) and the compiler
catches far more: bounds checks, uninitialized variables, unused imports.

## Anatomy of a program

```odin
package main

import "core:fmt"
import "core:os"
import "core:strconv"

main :: proc() {
	fmt.println("args:", len(os.args))
	for arg, i in os.args {
		fmt.printf("  os.args[%d] = %s\n", i, arg)
	}

	n := 10
	if len(os.args) > 1 {
		value, ok := strconv.parse_int(os.args[1])
		if ok {
			n = value
		}
	}
	fmt.println("limit:", n)
}
```

Things to notice:

- `main :: proc() { ... }` — `::` declares a **constant**. `main` is a constant
  whose value is a procedure. No return type: Odin programs don't return an exit
  code from `main`; call `os.exit(1)` explicitly when you need one.
- `n := 10` — `:=` declares a **mutable variable** with inferred type. There is
  no `val`/`var` split: everything declared with `:=` is mutable. If you want a
  constant, that's `N :: 10` (compile-time) — the Kotlin `val` intuition of
  "read-only but runtime-computed" has no direct equivalent.
- `value, ok := strconv.parse_int(...)` — multiple return values are everywhere.
  This replaces both exceptions and `toIntOrNull()`.
- `for arg, i in os.args` — iteration with value + index, like
  `for ((i, arg) in args.withIndex())`.
- No semicolons needed, no `fun` keyword, braces are mandatory.

## Types

| Kotlin | Odin | Watch out for |
|---|---|---|
| `Int` | `int` | Pointer-sized (64-bit on your machine), like C's `ssize_t` |
| `Int` (fixed) | `i32` | Explicit sizes: `i8 i16 i32 i64`, unsigned `u8 u16 u32 u64` |
| `Long` | `i64` | |
| `Boolean` | `bool` | Built-in, no import needed |
| `Char` | `u8` / `byte` (ASCII) or `rune` (i32, a Unicode code point) | A `u8` is a number, `'A' == 65`; `'中'` is a `rune` |
| `String` | `string` | Immutable byte view, **not** NUL-terminated (module 04) |
| `Double` / `Float` | `f64` / `f32` | Float literals default to `f64` |
| `Unit` | no return type at all | A proc either returns something or doesn't |
| `Any` | `any` | A boxed type+pointer pair (module 05); powers `fmt.println` |

**No implicit conversions.** Kotlin widens `Int` to `Long` for you; Odin never
converts silently, not even `i32` → `int`:

```odin
a: i32 = 5
b: int = int(a)      // explicit cast required
c := f64(a)          // same syntax for numeric conversion
```

This feels pedantic for a day and then saves you from a whole category of bugs.

## Printing

`fmt.println(x)` prints any value; `fmt.printf` uses specifiers:

`%v` any value · `%d` integer · `%s` string · `%q` quoted string · `%c` rune ·
`%f` float · `%p` pointer · `%t` bool · `%%` literal percent

Unlike C's `printf`, `%v` is **type-safe** — `fmt` inspects the actual type at
runtime via the `any` mechanism. Wrong specifier is ugly output, not undefined
behavior.

## Control flow

Almost everything carries over, with upgrades:

```odin
// if — no parens, braces mandatory
if n > 5 { ... } else { ... }

// for is the ONLY loop keyword
for i in 0..<10 { ... }        // range, like 0 until 10  (half-open)
for i in 0..=10 { ... }        // inclusive
for { ... }                    // while(true)
for n > 0 { ... }              // while
for item in items { ... }      // for-each over a slice/array
for item, i in items { ... }   // with index

// switch: no fallthrough by default (fallthrough is an explicit keyword),
// cases can be ranges and multiple values
switch n {
case 0:
	fmt.println("zero")
case 1..=9:
	fmt.println("small")
case 10, 20:
	fmt.println("round")
case:
	fmt.println("other")       // default case
}
```

Two traps for Kotlin developers:

- Odin's `when` is **compile-time** conditional compilation (like `#if`), *not*
  Kotlin's `when`. The runtime `when` is `switch`.
- `break`/`continue` work as usual; there are no labeled loops, but Odin doesn't
  need them often thanks to `or_break`/`or_continue` (module 06).

## Exercises

Do these in `exercises/01-*/`. `odin check . -vet` must pass silently; then
`odin run .`.

1. **fizzbuzz** — print 1..N, where N comes from `os.args[1]` (default 100).
   Classic rules: multiples of 3 → `Fizz`, 5 → `Buzz`, both → `FizzBuzz`.
   Use `strconv.parse_int` and keep the default when the arg is missing *or*
   garbage.
2. **temperature converter** — `./temp 100 C` prints `212.0 F`, `./temp 32 F`
   prints `0.0 C`. Validate both arguments exist and the unit is `C` or `F`;
   print usage to stderr (`fmt.eprintln`) and `os.exit(1)` on bad input.
   (`strconv.parse_f64` parses floats.)
3. **sizes** — print `size_of` every type in the table above (`size_of(int)`,
   `size_of(rune)`, `size_of(string)`…). Note anything surprising — e.g. why a
   `string` is 16 bytes and what those bytes must be.

## Self-check

- [ ] You can explain the difference between `:=`, `::`, and `=`
- [ ] You know why Odin rejects `i32 + int` without a cast, and you approve
- [ ] You used `os.args` without crashing when arguments are missing
- [ ] `odin check . -vet` is silent on every exercise

Next: [Module 02 — Procedures & Packages](02-procedures-and-packages.md)
