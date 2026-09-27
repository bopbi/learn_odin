# learn_odin

A personal Odin-learning workspace, written by an Android developer coming from
Kotlin/Java (and fresh off `back_to_c`). The goal: build Odin instincts —
explicit memory with `defer` and allocators, errors as values, tagged unions —
and prove them by writing a small HTTP server from scratch.

## Layout

- `curriculum/` — an 11-module course (`00`–`10`) that maps JVM concepts to
  Odin reality (GC → `defer`/allocators, exceptions → multiple returns +
  `or_return`, `sealed class` → tagged `union`). Start at `curriculum/README.md`.
- `capstone/http-server/` — reference implementation of the capstone: a
  ~150-line static-file HTTP server. The capstone deliberately mirrors the
  `back_to_c` one so the two can be compared side by side.
- `exercises/` — exercise code, one folder per exercise.

## Requirements

macOS with Odin (`brew install odin`, currently `dev-2026-09`). No other
dependencies — the `core:` and `vendor:` collections ship with the compiler.

## Quick start

Run the capstone HTTP server:

```
odin build capstone/http-server -out:capstone/http-server/server
cd capstone/http-server && ./server
curl -i http://localhost:8080/
```

Work through the curriculum:

```
open curriculum/README.md   # or just read it in your editor
```

## Conventions

- One directory = one Odin package; exercise folders are self-contained.
- `odin check . -vet` must be silent; from module 03 on, programs run under
  `mem.Tracking_Allocator` and exit with zero leaks.
- Agent-facing project notes live in `AGENTS.md` (`CLAUDE.md`, `GEMINI.md`,
  `COPILOT.md`, and `.github/copilot-instructions.md` are symlinks to it).
