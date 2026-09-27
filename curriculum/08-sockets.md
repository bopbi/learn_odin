# Module 08 — Sockets

**Goal:** TCP from Odin's `core:net` — listen, accept, recv, send. Everything the
capstone is made of.
**Time:** ~2 hours

## The mental model (unchanged from C)

```
socket → bind → listen → accept → recv/send → close
```

If you did `back_to_c` module 08, the protocol is identical — Beej's Guide still
applies. What changes is the API surface: no `errno`, no `sockaddr` casting, and
errors arrive in the return tuple.

## core:net in five calls

```odin
import "core:net"

// 1. parse an address
ep, ok := net.parse_endpoint("0.0.0.0:8080")   // (Endpoint, bool)
if !ok { /* bad address */ }

// 2. listen (socket+bind+listen in one)
listener, err := net.listen_tcp(ep)            // (TCP_Socket, Network_Error)
if err != nil {
	fmt.eprintln("listen failed:", err)
	return
}
defer net.close(listener)

// 3. accept one connection
client, source, aerr := net.accept_tcp(listener)
if aerr != nil { /* try again or give up */ }
defer net.close(client)
fmt.println("connection from", source)         // endpoints print nicely

// 4. receive — may return FEWER bytes than the buffer holds; TCP is a stream
buf: [4096]byte
n, rerr := net.recv(client, buf[:])
if rerr != nil { /* closed or error */ }
request_bytes := buf[:n]

// 5. send — same caveat: check bytes_written, loop if partial
response := "hello"
written, serr := net.send(client, transmute([]byte)response)
```

Notes for a JVM developer (sockets were always `java.net.Socket`'s problem):

- `recv` returning `n == 0` means the peer closed cleanly. `n < len(buf)` is
  normal — you must loop until you have a complete HTTP request (the capstone's
  milestone 2 is exactly this).
- `transmute([]byte)response` reinterprets a `string` as bytes — the one place
  you need it, since strings are already `[]u8`-shaped.
- Every call returns a typed error; `net` errors are unions you can switch on if
  you care (e.g. distinguish "peer closed" from "real error").

## One connection at a time is fine

The capstone is deliberately a **blocking, sequential** server: accept, handle,
close, repeat. That's not a toy simplification to be ashamed of — it's the
correct first version:

- Concurrency in Odin means `core:thread` + your own synchronization — there are
  no coroutines. Threads are a *later* topic, not a learning prerequisite.
- A sequential server can't race, which is exactly what you want while learning
  ownership and parsing. (Stretch goal in module 09: one thread per connection,
  each with its own arena — a genuinely clean design in Odin.)

## Exercises

In `exercises/08-*/`:

1. **echo server** — listen on 8080; accept; `recv` once; `send` the same bytes
   back; close. Test: `nc localhost 8080`, type, see it echo. Then `curl
   http://localhost:8080/` and print what curl actually sends — you're looking at
   a real HTTP request on the wire.
2. **request dumper** — loop `recv` until you've seen `"\r\n\r\n"` (end of HTTP
   headers; use `strings.contains(string(buf[:total]), "\r\n\r\n")` — you may
   need several recvs), then print the whole request. This is the capstone's
   milestone 2, standalone.
3. **fixed response** — after dumping, always reply with a hard-coded
   `"HTTP/1.1 200 OK\r\nContent-Length: 5\r\n\r\nhello"`. Open
   `http://localhost:8080/` in a browser. You now have the world's most boring
   web server — and every remaining capstone step is just making the response
   less boring.

## Self-check

- [ ] You know why one `recv` is never enough, and your loop handles it
- [ ] `close` on both sockets, on every path (thank you, `defer`)
- [ ] You saw a real browser's request headers in your terminal
- [ ] Zero leaks; no crash when the client disconnects mid-request

Next: [Module 09 — Capstone: HTTP Server](09-capstone-http-server.md)
