# Module 07 — Context, Maps & JSON

**Goal:** understand `context` — Odin's most unusual feature — plus two everyday
tools the capstone wants: `map` and `core:encoding/json`.
**Time:** ~2–3 hours

## context: dependency injection, built into the language

Kotlin coroutines have `CoroutineContext`; Android has `Context`; Dagger/Hilt
inject dependencies through graphs. Odin's answer is one implicit variable named
`context`, threaded through every call invisibly:

```odin
main :: proc() {
	fmt.println(context.allocator)       // who provides memory right now
	context.allocator = my_arena         // swap it — every new/make below uses it
}
```

`context` carries (among others):

- `context.allocator` — where `new`/`make` allocate (module 03)
- `context.temp_allocator` — a scratch arena, cheap to `free_all`
- `context.logger` — where `log.info(...)` writes (`core:log`)

Why this matters to you:

1. **Library procs take an optional allocator** (`proc(..., allocator := context.allocator)`),
   so *you* decide the memory policy at the top of the program, and libraries
   obey. In the capstone you'll give each connection its own arena and free the
   whole request's memory in one shot.
2. It explains signatures you've already used: `os.read_entire_file(name, allocator)`
   wants an allocator explicitly; `strings.split(line, " ")` quietly defaults to
   `context.allocator`. Same mechanism, different defaults.
3. Scoping trick: `context.user_ptr`/`context.user_index` let you smuggle app
   state through callbacks — Odin's answer to captured state without closures.

## map: the one built-in collection with keys

```odin
headers := make(map[string]string)     // like HashMap — allocates
defer delete(headers)

headers["Content-Type"] = "text/html"
headers["Content-Length"] = "42"

if ct, ok := headers["Content-Type"]; ok {   // lookup with presence check
	fmt.println(ct)
}
if "Server" not_in headers { ... }            // membership test
delete_key(&headers, "Content-Length")
for k, v in headers { fmt.println(k, v) }
```

- `m[k]` returns the zero value when missing — always use the `v, ok :=` form if
  zero is a valid value.
- Iteration order is unspecified (like `HashMap`).

## JSON: encoding/json

Android devs live in JSON (Retrofit, Moshi, Gson). Odin's is reflection-driven
and struct-shaped:

```odin
import "core:encoding/json"

Todo :: struct {
	id:        int   `json:"id"`,
	title:     string,
	completed: bool,
}

t := Todo{id = 1, title = "learn odin"}

// marshal — returns bytes, you own them
data, err := json.marshal(t)           // opt: json.Marshal_Options{.Pretty} via 2nd arg
defer delete(data)
fmt.println(string(data))              // {"id":1,"title":"learn odin","completed":false}

// unmarshal — into a struct you provide
t2: Todo
err2 := json.unmarshal(data, &t2)
```

Field names become JSON keys verbatim; the `json:"name"` tag overrides. That's
the whole framework — no annotations processor, no codegen.

## Exercises

In `exercises/07-*/`:

1. **headers round-trip** — parse `"Content-Type: text/html\r\nHost: x\r\n"` into
   a `map[string]string` (trim the value), then serialize it back with a
   `strings.Builder`. This *is* the capstone's header layer.
2. **json api** — define a `struct` matching `https://jsonplaceholder.typicode.com/todos/1`'s
   shape, unmarshal a hard-coded JSON literal into it, change a field, marshal
   back with `.Pretty` and print. (No HTTP client yet — parsing only.)
3. **request-scoped arena** — simulate one HTTP request: set
   `context.allocator` to a `mem.Arena` (`core:mem`, look up
   `mem.arena_init`/`arena_allocator` in the source), do all your parsing
   allocations in it, and `mem.arena_destroy` once at the end. Run with the
   tracking allocator *behind* the arena and confirm one big free instead of
   many small ones.

## Self-check

- [ ] You can explain `context.allocator` to a colleague using Dagger as the analogy
- [ ] `v, ok := m[k]` is reflexive; you never trust bare `m[k]`
- [ ] You marshalled and unmarshalled a struct without a single annotation processor
- [ ] You see why per-request arenas beat per-request GC pressure

Next: [Module 08 — Sockets](08-sockets.md)
