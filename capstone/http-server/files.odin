package main

import "core:os"
import "core:path/filepath"
import "core:strings"

// serve_path maps a URL path to a file under root and reads it.
// The returned body is owned by the caller (delete it); content_type is a
// string literal, valid on status 200.
serve_path :: proc(root, url_path: string) -> (body: []byte, status: int, content_type: string) {
	// directory traversal check — the classic static-server bug
	if strings.contains(url_path, "..") {
		return nil, 403, ""
	}

	path := url_path
	if path == "/" {
		path = "/index.html"
	}
	full := strings.concatenate({root, path})
	defer delete(full)

	if !os.is_file(full) {
		return nil, 404, ""
	}
	data, err := os.read_entire_file(full, context.allocator)
	if err != nil {
		return nil, 404, ""
	}
	return data, 200, content_type_for(path)
}

content_type_for :: proc(path: string) -> string {
	ext := filepath.ext(path)
	switch ext {
	case ".html": return "text/html"
	case ".css":  return "text/css"
	case ".js":   return "application/javascript"
	case ".txt":  return "text/plain"
	case ".png":  return "image/png"
	case ".jpg", ".jpeg": return "image/jpeg"
	case ".json": return "application/json"
	case:         return "application/octet-stream"
	}
}
