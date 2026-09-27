# Module 10 — Bonus: raylib (the "showcase" flavor)

**Goal:** optional detour — open a window, move a square, see why Odin's
community is game-shaped. Purely for joy; nothing here feeds the capstone.
**Time:** ~1–2 hours

## Why this module exists

Odin's showcase page is games and visualizations because the language is built
for them: no GC pauses, value types, SIMD-friendly arrays, and C-library bindings
that ship with the compiler (`vendor/raylib`, `vendor/sdl3`, `vendor/miniaudio`).
If the HTTP server felt familiar from your Android/C background, this is the
other side of Odin culture.

## A window and a moving square

`vendor:raylib` is a complete binding — no install step:

```odin
package main

import rl "vendor:raylib"

main :: proc() {
	rl.InitWindow(800, 450, "odin + raylib")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	pos := rl.Vector2{400, 225}
	speed: f32 = 300

	for !rl.WindowShouldClose() {
		dt := rl.GetFrameTime()          // seconds since last frame

		if rl.IsKeyDown(.RIGHT) { pos.x += speed * dt }
		if rl.IsKeyDown(.LEFT)  { pos.x -= speed * dt }
		if rl.IsKeyDown(.DOWN)  { pos.y += speed * dt }
		if rl.IsKeyDown(.UP)    { pos.y -= speed * dt }

		rl.BeginDrawing()
		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawRectangleV(pos, {50, 50}, rl.MAROON)
		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
}
```

```
odin run .
```

Things to notice, connecting back to the course:

- `import rl "vendor:raylib"` — vendor packages import like core ones, with an
  alias because `raylib.` is long.
- `rl.Vector2{400, 225}` and `{50, 50}` — positional struct literals; the second
  infers its type from the parameter. No constructors here either.
- The game loop is just a `for` loop: poll input, update state, draw. If you've
  done Android `SurfaceView`/`Canvas` or Jetpack Compose's `LaunchedEffect`
  frame loops, this is the same idea with zero framework.
- Frame-time-based movement (`speed * dt`) — the classic game-dev idiom.

## Where to go from here

- `ls $(odin root)/vendor/raylib` — the bindings are readable; `examples/` inside
  the raylib repo all translate mechanically to Odin.
- `vendor:microui` for immediate-mode UI, `vendor:miniaudio` for sound.
- The Odin Discord `#showcase` channel — post the square, get cheered on.

## Self-check

- [ ] A window opened, a square moved, 60 FPS
- [ ] You can explain why this style of programming (tight loop, value types,
  no GC) is where Odin shines — and why the HTTP server was still the right
  first project for *you*

That's the course. Keep the HTTP server around as your reference — the next
Odin project you build, build it without one.
