# Agent Guide

## Project Overview

A personal Odin-learning workspace for an Android developer coming from
Kotlin/Java (companion to the sibling `back_to_c` repo, whose capstone this one
deliberately mirrors).

- `curriculum/` — step-by-step Odin course. Start at `curriculum/README.md`; modules are numbered `00`–`10` (`10` is an optional raylib bonus).
- `capstone/http-server/` — reference implementation of the capstone: a simple static-file HTTP server in Odin (4 files, one `package main`).
- `exercises/` — where exercise code is written while working through the curriculum (one folder per exercise).

## Build, Test, and Lint

- Toolchain: Odin via Homebrew (macOS), currently `dev-2026-09`. No external dependencies; `core:` and `vendor:` ship with the compiler.
- Run a package: `odin run <dir>` (e.g. `odin run exercises/01-fizzbuzz`).
- Type-check with vet: `odin check <dir> -vet` — must be silent.
- Capstone: `odin build capstone/http-server -out:capstone/http-server/server`; run `./server` from `capstone/http-server/` (it serves `www/` relative to the working directory); test with `curl -i http://localhost:8080/`.
- Stdlib source is the docs: `odin root`, then browse `core/` and `vendor/`.

## Conventions

- One directory = one Odin package; every file in it shares `package` name and scope.
- Exercise folders are named `exercises/<module>-<name>/` and are self-contained.
- From module 03 on, programs run under `mem.Tracking_Allocator` and should exit with zero leaks.
- Reference code is written for a learner: simple, commented where the Odin idiom is non-obvious to a JVM developer.
- Verify Odin API signatures against `$(odin root)/core/...` before writing or changing code — the stdlib evolves between dev releases.

## Agent Rules

- Do not modify files outside the project root (the sibling `back_to_c` repo is reference-only).
- Do not run `git commit`, `git push`, or other destructive git mutations unless explicitly asked.
- Do not create large files, test scaffolds, or documentation unless requested or required by the task.
- Prefer plain, reversible changes. If an action is hard to undo, ask first.
- Keep responses concise and focused on the task at hand.
