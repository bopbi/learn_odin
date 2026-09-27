# Module 09 — Capstone: HTTP Server

**Goal:** put it all together — a static-file HTTP server in Odin, from sockets
up. Then compare it with your `back_to_c` C version: same protocol, very
different ergonomics.
**Time:** ~4–6 hours

## The spec

```
./server [port]        # default 8080
```

- Serves files from `www/` relative to the working directory.
- `GET /` → `www/index.html`; `GET /<path>` → `www/<path>`.
- Missing file → `404 Not Found`; paths containing `..` → `403 Forbidden`;
  unsupported method → `405 Method Not Allowed`.
- Correct `Content-Type` for `.html`, `.css`, `.js`, `.txt`, `.png`, `.json`;
  `application/octet-stream` otherwise.
- One connection at a time (sequential accept loop). Handle one request per
  connection, then close (HTTP/1.0 style — no keep-alive; declare
  `Connection: close`).
- Port comes from `os.args`; garbage → usage + `os.exit(1)`.

## Milestones — commit after each

1. **Skeleton** — parse the port (module 01: `strconv.parse_int` + `or_else`),
   listen (module 08), accept-loop that closes immediately. `curl` should get an
   empty reply, not a hang.
2. **Receive a full request** — loop `recv` into a growing buffer until
   `"\r\n\r\n"` appears (module 08 exercise 2).
3. **Parse** — request line → `method, path, version` (module 04 exercise 2:
   views into the buffer, no copying). Headers into a `map[string]string`
   (module 07 exercise 1). `Request :: struct` (module 05).
4. **Route & read** — map path → file (module 06 exercise 2: traversal check,
   `os.is_file`, `os.read_entire_file`). Status codes via your `Status` enum.
5. **Respond** — build status line + headers + body with a `strings.Builder`
   (module 04 exercise 3). `net.send` in a loop until all bytes are written.
6. **Polish** — `Content-Type` table (a `map[string]string` from extension to
   type is fine), graceful errors on every failure path, zero leaks under the
   tracking allocator even after `curl` hammers it (`for i in {1..100}; do curl
   -s localhost:8080/ > /dev/null; done`).

## Architecture hint

```
main.odin    — arg parsing, listen, accept loop
request.odin — Request struct + parser (returns views into the recv buffer)
respond.odin — status text, header building, send loop
files.odin   — path safety, read, content-type
```

All in one directory, all `package main` — four files, one scope, no imports
between them. That's the Odin way (module 02).

## The comparison that makes it click

When yours works, diff it against two references:

1. `capstone/http-server/` in this repo — the Odin reference implementation.
2. `../back_to_c/capstone/http-server/server.c` — your C version.

Write down, concretely: where did `defer` replace goto-cleanup? Where did slices
replace `char *` + length pairs? Where did `(value, err)` replace `errno`? How
many lines did `strings.Builder` save vs manual `snprintf` bookkeeping? That
list is your personal "why Odin" document.

## Stretch goals (pick any)

- **Per-connection arena** — set `context.allocator` to an arena around request
  handling; one `free_all` per request. Run the leak tracker behind it.
- **Thread per connection** — `core:thread`, each connection on its own thread
  with its own arena. Watch out: the recv buffer's lifetime now crosses a
  thread boundary — ownership discipline from module 03 applies for real.
- **JSON endpoint** — `/api/status` returning `json.marshal`ed server stats
  (uptime, requests served). Module 07 pays off.
- **Logging** — `core:log` with `context.logger`; log method, path, status, ms.

## Self-check

- [ ] `curl -i http://localhost:8080/` shows headers *and* body
- [ ] `curl -i http://localhost:8080/nope` → 404; `curl -i --path-as-is
  http://localhost:8080/../server` → 403 or 404, never the file
- [ ] Browser renders `index.html` with its CSS/JS
- [ ] 100 sequential requests, zero leaked bytes
- [ ] You wrote the Odin-vs-C comparison list

Next: [Module 10 — Bonus: raylib](10-bonus-raylib.md)
