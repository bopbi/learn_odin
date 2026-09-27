# Module 03 — Pointers & Memory

**Goal:** own your memory. Understand pointers, allocators, and `defer` — the
three things that replace the garbage collector.
**Time:** ~3 hours

## The deal

```
Kotlin: val s = String(...)   // GC frees it eventually; you never think about it
C:      char *s = malloc(...) // you free() it, exactly once, or leak/crash
Odin:   s := new(...)         // you delete it, but defer + allocators make it civilized
```

If you did `back_to_c`, the ownership discipline is the same. What's new is that
Odin gives you tooling: `defer` for cleanup, swappable **allocators** for policy,
and a **tracking allocator** that finds leaks for you.

## Pointers

```odin
x: int = 42
p: ^int = &x        // ^int is "pointer to int" (like Kotlin's nothing — JVM hides these)
p^ = 43             // dereference with postfix ^  (C's *p)
fmt.println(x)      // 43

var_nil: ^int       // zero value of any pointer is nil
```

- `&` takes an address, postfix `^` dereferences. Zero value of everything is
  zero/nil — Odin has **no uninitialized memory** in the language semantics
  (locals are zeroed unless you write `---`).
- `nil` dereference panics at runtime with a stack trace — better than C's
  segfault, worse than Kotlin's `?.`. Idiomatic Odin avoids nullable pointers in
  favor of `Maybe(T)` or `(T, bool)` returns (module 05/06).
- There is **no pointer arithmetic** on `^T` (that lives on `rawptr`/`[^]T` for
  interop). You won't miss it — slices (module 04) cover the real use cases.

## Allocating: new, make, delete, free

```odin
p := new(int)       // one value on the heap, zeroed; returns ^int
defer delete(p)     // free it when the scope exits
p^ = 42

s := make([]int, 10)    // a 10-element slice, heap-backed
defer delete(s)
```

- `new(T)` → `^T`, paired with `delete(ptr)`
- `make([]T, n)` / `make([dynamic]T)` / `make(map[K]V)` → paired with `delete(x)`
- `free(ptr)` is the raw "give memory back" underneath; `delete` knows the type.

**`defer` runs at scope exit, LIFO** — like Kotlin's `use {}` / try-finally, but
one line and no nesting:

```odin
f, err := os.open("data.txt")
if err != nil { return }
defer os.close(f)       // runs on every return path, however you leave
```

This is the single biggest quality-of-life upgrade over C. Cleanup sits next to
acquisition, in reading order.

## Where does the memory come from? Allocators.

Every allocation goes through `context.allocator` — an implicit, swappable
strategy object (module 07 goes deep; today you just need to know it exists):

```odin
p := new(int)                                  // uses context.allocator
p := new(int, allocator = context.temp_allocator)  // or pick another
```

- `context.allocator` — the default heap allocator (malloc-backed).
- `context.temp_allocator` — an arena that's cheap to free all at once; great for
  per-request scratch memory (your HTTP server will use it per connection).

Think Dagger/Hilt, but for memory: the *caller* controls the policy, callees just
use whatever `context` says.

## Finding leaks: the tracking allocator

Odin's answer to Android Studio's LeakCanary / C's AddressSanitizer — and it's
part of normal development, not an emergency tool:

```odin
package main

import "core:fmt"
import "core:mem"

main :: proc() {
	track: mem.Tracking_Allocator
	mem.tracking_allocator_init(&track, context.allocator)
	context.allocator = mem.tracking_allocator(&track)
	defer {
		for _, leak in track.allocation_map {
			fmt.printf("%v leaked %m bytes\n", leak.location, leak.size)
		}
		mem.tracking_allocator_destroy(&track)
	}

	// ... your program here; every new/make is now recorded
	p := new(int)   // forget delete(p) and you'll see exactly where it leaked
	p^ = 1
}
```

Run it, see the leak, add `defer delete(p)`, watch it go quiet. This is the
feedback loop that makes manual memory learnable. (`%m` formats byte counts.)

## Exercises

In `exercises/03-*/` — put the tracking allocator at the top of every `main` from
now on; the goal is **zero leaks reported**.

1. **swap** — write `swap :: proc(a, b: ^int)` that swaps what two pointers point
   at. Call it on two locals; print before/after. (This is the classic C pointer
   exercise; Odin's postfix `^` is the only new syntax.)
2. **growable buffer** — write `sum_file :: proc(path: string) -> (int, bool)`:
   read the file with `os.read_entire_file` (preview of module 06 — it returns
   `([]byte, os.Error)`), `defer delete(data)`, then sum every byte. Deliberately
   remove the `defer` once and watch the tracker catch you.
3. **temp arena** — allocate 1000 strings with `strings.clone(s,
   allocator = context.temp_allocator)` in a loop, print the total length, then
   `free_all(context.temp_allocator)` once at the end. Compare with the
   delete-each version. Feel the arena.

## Self-check

- [ ] You can read `^`, `&`, `^int` aloud ("dereference", "address of", "pointer to int")
- [ ] `defer` order makes sense (LIFO) and you reach for it instinctively
- [ ] You know what `context.allocator` is, even if module 07 will formalize it
- [ ] Every exercise exits with zero reported leaks

Next: [Module 04 — Arrays, Slices & Strings](04-arrays-slices-strings.md)
