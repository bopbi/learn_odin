package main

import "core:fmt"
import "core:net"
import "core:os"
import "core:strconv"


// Sequential static-file HTTP server: accept, handle, close, repeat.
// Serves www/ from the working directory. HTTP/1.0 style: one request
// per connection, "Connection: close".

main :: proc() {
	port := 8080
	if len(os.args) > 1 {
		value, ok := strconv.parse_int(os.args[1])
		if !ok {
			fmt.eprintfln("usage: %s [port]", os.args[0])
			os.exit(1)
		}
		port = value
	}

	listener, err := net.listen_tcp(net.Endpoint{address = net.IP4_Address{0, 0, 0, 0}, port = port})
	if err != nil {
		fmt.eprintfln("listen failed: %v", err)
		os.exit(1)
	}
	defer net.close(listener)
	fmt.printfln("serving www/ on http://localhost:%d", port)

	for {
		client, source, aerr := net.accept_tcp(listener)
		if aerr != nil {
			fmt.eprintfln("accept failed: %v", aerr)
			continue
		}
		handle_connection(client)
		_ = source
	}
}

handle_connection :: proc(client: net.TCP_Socket) {
	defer net.close(client)

	raw, ok := recv_request(client)
	if !ok {
		return
	}
	defer delete(raw)

	req, pok := parse_request(raw)
	if !pok {
		send_response(client, 400, "text/plain", transmute([]byte)string("bad request"))
		return
	}
	defer delete(req.headers)
	fmt.printfln("%s %s", req.method, req.path)

	if req.method != "GET" && req.method != "HEAD" {
		send_response(client, 405, "text/plain", transmute([]byte)string("method not allowed"))
		return
	}

	body, status, content_type := serve_path("www", req.path)
	defer delete(body)
	if status != 200 {
		// error bodies are plain text
		send_response(client, status, "text/plain", transmute([]byte)string(status_text(status)))
		return
	}

	if req.method == "HEAD" {
		// HEAD: headers with the real Content-Length, but no body
		send_response(client, status, content_type, nil, override_length = len(body))
	} else {
		send_response(client, status, content_type, body)
	}
}
