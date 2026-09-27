# Module 00 — Setup

**Goal:** get the Odin toolchain working and learn the three commands you'll use
for the entire course.
**Time:** ~30 minutes

## Install

On macOS with Homebrew (this machine already has it):

```
brew install odin
odin version        # e.g. dev-2026-09:a2fb372b7
```

Other platforms: <https://odin-lang.org/docs/install/>. Odin is a moving target —
the dev releases come monthly and the standard library evolves. Pin your learning
to whatever `odin version` says and don't mix old blog posts with new compilers.

## The three commands

There is no Gradle, no package manager, no daemon. The `odin` binary is the whole
build system:

```
odin run .          # compile the package in the current dir and run it
odin build .        # compile to a binary (named after the directory)
odin check . -vet   # type-check only, with extra vet warnings — fast feedback
```

Conventions you can ignore for now but will meet later:

- `odin run . -file` — run a package that is a single file, ignoring neighbors.
- `odin build . -o:speed` — optimized build (like a release build).
- `odin test .` — runs procedures annotated `@(test)` using `core:testing`.

## A package is a directory

In Kotlin a file declares its package and can live anywhere. In Odin it's
stricter and simpler:

> **One directory = one package.** Every `.odin` file in a directory starts with
> the same `package` line, and all files in the directory share one scope.

Create a scratch dir and your first program:

```
mkdir -p hello && cd hello
cat > main.odin <<'EOF'
package main

import "core:fmt"

main :: proc() {
	fmt.println("hello from odin")
}
EOF
odin run .
```

## Your IDE: the standard library source

Odin's docs are improving, but the ground truth is the source of the `core:`
collection, and it is unusually readable. Find it:

```
odin root          # e.g. /opt/homebrew/Cellar/odin/2026-09/libexec
ls $(odin root)/core
ls $(odin root)/vendor
```

- `core/` — the standard library: `fmt`, `os`, `strings`, `net`, `mem`, `encoding/json`…
- `vendor/` — bundled C libraries with Odin bindings: `raylib`, `sdl3`, `stb`, `miniaudio`…

When you wonder "how do I split a string?", the answer is
`grep -n "^split" $(odin root)/core/strings/strings.odin` — and you can read the
implementation right there. There is also <https://pkg.odin-lang.org/core/> if you
prefer a browser.

## Editor

Any LSP-capable editor + [ols](https://github.com/DanielGavin/ols) (Odin Language
Server) works. VS Code has an official Odin extension. Not required for this
course — the compiler's errors are good enough on their own.

## Self-check

- [ ] `odin version` prints a version
- [ ] You ran the hello world above with `odin run .`
- [ ] `odin check . -vet` exits silently (no output = no errors)
- [ ] You found `core/fmt/fmt.odin` via `odin root` and skimmed `println`'s signature

Next: [Module 01 — First Program](01-first-program.md)
