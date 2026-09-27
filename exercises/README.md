# exercises

One folder per exercise, named `exercises/<module>-<name>/` (e.g.
`01-fizzbuzz/`), each a self-contained Odin package.

```
mkdir -p 01-fizzbuzz && cd 01-fizzbuzz
# write main.odin (package main)
odin check . -vet     # must be silent
odin run .
```

Rules for yourself:

- Type the code by hand — the typing is the learning.
- `odin check . -vet` silent = done.
- From module 03 on, every `main` starts with the tracking allocator
  (`mem.Tracking_Allocator`) and exits with zero leaks reported.
