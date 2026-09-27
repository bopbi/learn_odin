package main

import "core:fmt"
import "core:net"
import "core:strings"

status_text :: proc(status: int) -> string {
	switch status {
	case 200: return "OK"
	case 400: return "Bad Request"
	case 403: return "Forbidden"
	case 404: return "Not Found"
	case 405: return "Method Not Allowed"
	case:     return "Internal Server Error"
	}
}

// send_response writes status line, headers and body, looping until every
// byte is out (net.send may write fewer bytes than given).
send_response :: proc(
	client: net.TCP_Socket,
	status: int,
	content_type: string,
	body: []byte,
	override_length := -1,
) {
	length := len(body)
	if override_length >= 0 {
		length = override_length
	}

	b := strings.builder_make()
	defer strings.builder_destroy(&b)
	fmt.sbprintf(&b, "HTTP/1.1 %d %s\r\n", status, status_text(status))
	fmt.sbprintf(&b, "Content-Type: %s\r\n", content_type)
	fmt.sbprintf(&b, "Content-Length: %d\r\n", length)
	fmt.sbprintf(&b, "Connection: close\r\n")
	strings.write_string(&b, "\r\n")

	header := strings.to_string(b)
	if !send_all(client, transmute([]byte)header) {
		return
	}
	if override_length < 0 {
		send_all(client, body)
	}
}

send_all :: proc(client: net.TCP_Socket, data: []byte) -> bool {
	remaining := data
	for len(remaining) > 0 {
		n, err := net.send(client, remaining)
		if err != nil || n == 0 {
			return false
		}
		remaining = remaining[n:]
	}
	return true
}
