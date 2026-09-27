package main

import "core:net"
import "core:strings"

Request :: struct {
	method:  string,
	path:    string,
	version: string,
	headers: map[string]string,
}

// recv_request reads until the blank line that ends the HTTP headers.
// The returned buffer is owned by the caller.
recv_request :: proc(client: net.TCP_Socket) -> (data: []byte, ok: bool) {
	buf := make([dynamic]byte)
	defer if !ok { delete(buf) }

	chunk: [4096]byte
	for {
		n, err := net.recv(client, chunk[:])
		if err != nil || n == 0 {
			return nil, false
		}
		append(&buf, ..chunk[:n])
		if strings.contains(string(buf[:]), "\r\n\r\n") {
			break
		}
		if len(buf) > 1 << 20 { // 1 MiB header limit
			return nil, false
		}
	}
	return buf[:], true
}

// parse_request parses the request line and headers.
// method/path/version are views into `raw` — no copying; raw must outlive them.
parse_request :: proc(raw: []byte) -> (req: Request, ok: bool) {
	text := string(raw)
	head_end := strings.index(text, "\r\n\r\n")
	if head_end < 0 {
		return {}, false
	}

	lines := strings.split_lines(text[:head_end])
	defer delete(lines)
	if len(lines) == 0 {
		return {}, false
	}

	parts := strings.split(lines[0], " ")
	defer delete(parts)
	if len(parts) != 3 {
		return {}, false
	}
	req.method = parts[0]
	req.path = parts[1]
	req.version = parts[2]

	req.headers = make(map[string]string)
	for line in lines[1:] {
		colon := strings.index(line, ":")
		if colon <= 0 {
			continue
		}
		req.headers[line[:colon]] = strings.trim_space(line[colon + 1:])
	}
	return req, true
}
