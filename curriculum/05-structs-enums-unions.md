# Module 05 — Structs, Enums & Unions

**Goal:** model data the Odin way — plain structs, real enums, and tagged unions,
which are Odin's answer to Kotlin's `sealed class`.
**Time:** ~3 hours

## Structs: data only, no methods

```odin
Request :: struct {
	method:  string,
	path:    string,
	headers: map[string]string,
}

req := Request{method = "GET", path = "/"}   // named fields, any order
fmt.println(req.path)
```

The JVM-developer adjustment:

- **No classes, no inheritance, no methods, no visibility keywords.** A struct is
  a layout of fields. Behavior is procedures that take the struct:
  `handle_request :: proc(req: ^Request)`.
- There is no `constructor`. Zero value is always valid-ish (all fields zeroed);
  named-field literals `T{field = v}` are how you build things. For invariants,
  write `make_request :: proc(...) -> Request` by convention.
- Struct equality with `==` compares field-by-field.
- There *is* composition via `using` (embeds another struct's fields/procs into
  the namespace) — powerful, but you don't need it for the capstone. Skip it for
  now; revisit when you see it in `core:`.

Kotlin mapping: `data class` minus the methods, minus the hierarchy.

## Enums: real ones

```odin
Method :: enum { GET, POST, HEAD, PUT, DELETE }

m := Method.GET
fmt.println(m)             // prints GET — enums know their names
fmt.println(int(m))        // 0 — and their ordinals
```

- `enum u8 { ... }` sets the backing type.
- `.GET` works wherever the type is known (in switches, struct literals) — no
  need to repeat `Method.`.
- No methods or fields on enums (Kotlin's enum-with-behavior). Put behavior in a
  `switch` — which brings us to:

## bit_set: EnumSet, but built-in

```odin
Permission :: enum { Read, Write, Execute }
Permissions :: bit_set[Permission]

p := Permissions{.Read, .Write}
p += {.Execute}            // add
if .Read in p { ... }      // test
```

A `bit_set` is an integer under the hood — the whole set fits in a register.
This replaces Java's `EnumSet` and all flag-`Int` patterns from Android.

## Unions: sealed classes without the ceremony

The headline feature for a Kotlin developer. A tagged union holds one of several
types, and the tag is checked by the compiler:

```odin
Response_Body :: union {
	string,           // in-memory text
	[]byte,           // raw bytes
	File_Ref,         // send a file (struct with path, etc.)
}

body: Response_Body = "hello"

// switch on the tag — x is SMART-CAST inside each case
switch b in body {
case string:
	net.send(sock, transmute([]byte)b)
case []byte:
	net.send(sock, b)
case File_Ref:
	serve_file(sock, b.path)
}
```

This is `when (body) { is String -> ... }` with the same exhaustiveness: add a
variant, every `switch` without a default tells you. Differences from Kotlin:

- Variants are **bare types**, not named subclasses — `union { int, string }` is
  fine. You can't attach per-variant data beyond the type itself being the data.
- `or_else` / `or_return` (module 06) build on the same pattern.
- `#partial switch` opts out of exhaustiveness when you only care about some tags.

## Maybe(T): the idiomatic nullable

Built into the language, `Maybe(T)` is literally `union { T }` plus sugar — a
value that may be absent, with the compiler forcing you to check:

```odin
find_user :: proc(id: int) -> Maybe(User) { ... }

if user, ok := find_user(42).?; ok {   // .? unwraps to (value, ok)
	fmt.println(user.name)
}
```

Kotlin's `User?` → Odin's `Maybe(User)`. Prefer it over `nil` pointers.

## any: how fmt.println prints everything

`any` is a boxed `(typeid, rawptr)` pair — the closest thing to JVM `Object`.
`fmt` uses it to print arbitrary values. Useful occasionally (JSON marshal takes
`any`); reach for it rarely — Odin code is usually statically typed.

## Exercises

In `exercises/05-*/`:

1. **http types** — define `Method :: enum`, `Request :: struct` (method, path,
   version, `headers: map[string]string`), and
   `Status :: enum { OK = 200, Not_Found = 404, ... }` (enums can have explicit
   values). Write `status_text :: proc(s: Status) -> string`.
2. **sealed result** — port this Kotlin to Odin with a union:
   `sealed interface Result { data class Ok(val data: String); data class
   HttpError(val code: Int); object NetworkError }`. Write
   `render :: proc(r: Result) -> string` with an exhaustive `switch`.
3. **json round-trip preview** — `json.marshal` a `Request` to a string and print
   it (module 07 formalizes this). Notice how struct field names become JSON
   keys, and try the `json:"name"` field tag:
   `method: string \`json:"method"\``.

## Self-check

- [ ] You've stopped reaching for classes; structs + procs feel natural
- [ ] You can write an exhaustive `switch` over a union and read the compiler
  error when a variant is missing
- [ ] `Maybe(T)` vs `^T` vs `(T, bool)`: you know the trade-offs
- [ ] You know what a `bit_set` replaces from the Java world

Next: [Module 06 — Errors & Files](06-errors-and-files.md)
