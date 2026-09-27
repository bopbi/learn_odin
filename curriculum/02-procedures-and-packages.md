# Module 02 — Procedures & Packages

**Goal:** organize code into procedures and packages; master multiple return
values — Odin's single most important idiom.
**Time:** ~2 hours

## Procedures

```odin
add :: proc(a, b: int) -> int {
	return a + b
}

// multiple params of one type share a type annotation: a, b: int
// explicit return type after ->
```

Calls look like Kotlin: `sum := add(2, 3)`. Differences:

- **Default parameter values** exist: `greet :: proc(name: string, greeting := "hello")`.
- There are no extension functions and no methods (module 05) — procedures are
  the only unit of behavior.

## Multiple return values — the idiom

This replaces exceptions, `Pair`, `Result<T>`, and most null-returning:

```odin
divide :: proc(a, b: f64) -> (f64, bool) {
	if b == 0 {
		return 0, false
	}
	return a / b, true
}

result, ok := divide(10, 3)
if !ok {
	fmt.eprintln("division failed")
}
```

Named results make signatures self-documenting (you'll see this all over
`core:`):

```odin
parse_port :: proc(s: string) -> (port: int, ok: bool) {
	value := strconv.parse_int(s) or_return    // returns (0, false) if parse failed
	if value < 1 || value > 65535 {
		return 0, false
	}
	return value, true
}
```

(`or_return` is module 06 — shown here as a preview of how natural it gets.)

Kotlin mapping: `fun divide(a, b): Double?` → `(f64, bool)`.
`Result<T>` / sealed `Either<E, T>` → `(T, Some_Error)` (module 06).

## Procedures are values

```odin
Operation :: proc(a, b: int) -> int    // a procedure TYPE, like a functional interface

apply :: proc(op: Operation, a, b: int) -> int {
	return op(a, b)
}

result := apply(add, 2, 3)             // pass the proc like a lambda
```

This is your replacement for Kotlin lambdas and SAM interfaces. (Capturing
closures exist but are rare in idiomatic Odin — pass state explicitly instead.)

## Overloading with procedure groups

No automatic overload resolution like Java's. You build an overload set
explicitly with `proc { ... }`:

```odin
sum_ints   :: proc(a, b: int) -> int     { return a + b }
sum_floats :: proc(a, b: f64) -> f64     { return a + b }

sum :: proc { sum_ints, sum_floats }     // call sum(1, 2) or sum(1.5, 2.5)
```

`core:` uses this heavily: `net.send`, `os.read_entire_file`, `strings.clone_from`
are all procedure groups.

## Packages

One directory = one package; all files share a scope. Create your own library by
making a directory next to your `main.odin`:

```
02-packages/
├── main.odin          (package main)
└── greet/
    └── greet.odin     (package greet)
```

```odin
// greet/greet.odin
package greet

hello :: proc(name: string) -> string { ... }
```

```odin
// main.odin
package main

import "greet"          // relative import of a sibling directory
import "core:fmt"

main :: proc() {
	fmt.println(greet.hello("odin"))
}
```

- Imports are file-scoped and **everything is name-qualified** (`greet.hello`,
  `fmt.println`). There are no star imports and no unqualified imports — you can
  always tell where a name comes from. JVM wildcard-import debates: solved.
- Only uppercase-first... no, wait: Odin exports **nothing by keyword**. Every
  top-level declaration in a package is visible to importers. If you want privacy,
  put it in a sub-package or use `@(private)` / `@(private="file")` attributes.
- Unused imports are a compile error. So are unused local variables. The compiler
  is your tidiness enforcer; `-vet` goes further (style hints, shadowing).

## Exercises

In `exercises/02-*/`:

1. **calculator package** — a `calc/` package with `add`, `sub`, `mul`, `div`
   procs, each `-> (f64, bool)` (false on div-by-zero), grouped under an
   overloaded `calc.eval(op: string, a, b: f64) -> (f64, bool)` that dispatches
   on the operator string. `main.odin` parses `./calc 10 / 3` from `os.args`.
2. **statistics** — `stats :: proc(values: []f64) -> (min, max, mean: f64)` using
   named results. Call it, print all three. (Slices preview: `[]f64` is just
   "a list of f64" for now — module 04 goes deep.)
3. **strategy** — define `Predicate :: proc(int) -> bool` and
   `count_if :: proc(items: []int, pred: Predicate) -> int`. Use it with a proc
   you wrote (`is_even`) and a lambda (`proc(x: int) -> bool { return x > 5 }`).

## Self-check

- [ ] You can write `(value, ok)` signatures without looking them up
- [ ] You know why `import` names are always qualified at the call site
- [ ] You made a procedure group and understand it resolves at compile time
- [ ] No unused imports or variables survive `odin check . -vet`

Next: [Module 03 — Pointers & Memory](03-pointers-and-memory.md)
