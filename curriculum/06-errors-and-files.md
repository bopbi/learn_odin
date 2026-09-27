# Module 06 — Errors & Files

**Goal:** Odin's error-handling idiom — no exceptions, no try/catch, and it's
better than you expect. Applied to file I/O, which the capstone needs for serving
static files.
**Time:** ~2–3 hours

## Errors are values

```odin
data, err := os.read_entire_file("www/index.html", context.allocator)
if err != nil {
	fmt.eprintln("read failed:", err)   // errors print with useful info
	return
}
defer delete(data)
```

- `os.Error` is a tagged **union** (`union #shared_nil`) — `nil` means "no
  error", otherwise it's a platform-specific payload. Same idea as Kotlin's
  `Result`, but it's just a return value, not a wrapper class.
- Nothing forces you to check `err` — the discipline is on you, like C. But
  unlike C, the value is right there in the return tuple, so the happy path and
  the error path are one line apart.

## The or_* family: Kotlin's `?.` and `?:`, generalized

These operators unwrap a `(value, ok)` or `(value, err)` pair:

```odin
// or_else — supply a default, like ?:
port := strconv.parse_int(os.args[1]) or_else 8080

// or_return — propagate the failure, like Rust's ? / Kotlin's throw
parse_port :: proc(s: string) -> (port: int, ok: bool) {
	value := strconv.parse_int(s) or_return   // parse failed → return (0, false)
	if value < 1 || value > 65535 { return 0, false }
	return value, true
}

// or_break / or_continue — inside loops
for arg in os.args[1:] {
	n := strconv.parse_int(arg) or_continue   // skip garbage args
	fmt.println(n)
}
```

`or_return` returns from the *current* proc when the trailing `ok`/`err` signals
failure — the other return values come from your proc's zero values (or named
result variables if you've set them). This is 80% of error handling in idiomatic
Odin, and it reads top-to-bottom like Kotlin with exceptions — except every
failure path is visible at the call site.

## Files

```odin
import "core:os"

// existence and type — for the capstone's 404 logic
if !os.exists(path)  { /* 404 */ }
if !os.is_file(path) { /* 403/404 */ }

// whole file at once — fine for small static files
data, err := os.read_entire_file(path, context.allocator)
defer delete(data)

// streaming, when you need it
f, err2 := os.open(path)
if err2 == nil {
	defer os.close(f)
	n, _ := os.read(f, buf)         // read into a []byte buffer
	_ = os.write(f, some_bytes)
}

// writing a whole file
err3 := os.write_entire_file("out.txt", transmute([]byte)"hello")
```

Error-handling pattern for the capstone: **check once at the boundary, then
decide the HTTP status**. `err != nil` from `read_entire_file` → 404 or 500;
never crash the server on a bad path.

## A note on panics

`odin` panics on bounds violations, nil dereferences of `^T`, failed `assert`s —
the JVM's unchecked-exception tier. Panics are for *bugs*, not user input. A
request for a missing file is user input: handle it with errors, not assert.

## Exercises

In `exercises/06-*/`:

1. **safe cat** — `./cat <path>` prints a file to stdout; missing/unreadable file
   prints `cat: <path>: <err>` to stderr and `os.exit(1)`. Multiple path args
   concatenated, like real `cat`. Use `or_else`-style handling per file so one
   bad file doesn't kill the rest.
2. **file server core** — write
   `serve_path :: proc(root, url_path: string) -> (body: []byte, status: int)`:
   join `root` + `url_path` (`core:path/filepath` or `strings.concatenate`),
   reject paths containing `..` (directory traversal — the classic static-server
   bug), read the file, return `(data, 200)` or `(nil, 404)`. Caller
   `delete`s the body.
3. **config parser** — parse a `key=value` config file into a
   `map[string]string` (preview of module 07's map). Missing file → defaults,
   not a crash. Malformed lines → skipped with a stderr warning.

## Self-check

- [ ] `or_return` / `or_else` / `or_continue` feel as natural as `?.` did
- [ ] You can explain when to panic vs return an error
- [ ] You blocked `..` traversal without being told twice
- [ ] Zero leaks (you're still running the tracking allocator, right?)

Next: [Module 07 — Context, Maps & JSON](07-context-maps-json.md)
