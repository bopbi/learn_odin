# capstone/http-server

Reference implementation of the module 09 capstone: a sequential static-file
HTTP server in Odin (~150 lines across 4 files, one `package main`).

## Run

```
odin build . -out:server
./server [port]          # default 8080; serves www/ from the working directory
curl -i http://localhost:8080/
```

## Files

- `main.odin` — arg parsing, listen, accept loop, per-connection flow
- `request.odin` — recv until end-of-headers; parse request line + headers
  (returned strings are views into the receive buffer)
- `respond.odin` — status text, header building, `send_all` loop
- `files.odin` — traversal check (`..`), read file, content-type table

## Deliberate limitations (learning scope, not bugs)

- One connection at a time; one request per connection (`Connection: close`).
- Only GET and HEAD.
- Small static files only — read fully into memory, no streaming.
- See module 09's stretch goals for threads, per-connection arenas, JSON, logging.
