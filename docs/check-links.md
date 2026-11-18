# `bin/check-links.sh`

Checks that each expected `~/.config/NAME` path is a symbolic link to the
corresponding `~/.dotfiles/config/NAME` directory.

```bash
~/.dotfiles/bin/check-links.sh
```

It takes no options. Its process exit status is useful in automation: `0`
means every check passed; `1` means at least one check failed.

### Commands and options

- `status=0` initializes the result to success.
- `for name in …; do … done` checks the same configuration list used by
  `set-links.sh`.
- `[ ! -d "$origin" ]` reports a missing source directory.
- `[ ! -L "$destiny" ]` reports a destination that is not a symbolic link.
- `readlink -e "$path"` resolves a path to its canonical existing target.
  Comparing the resolved source and destination detects broken links and links
  that point to the wrong directory.
- `echo` prints an `OK` or `ERROR` line for each item.
- `status=1` records any failure without stopping the remaining checks.
- `exit "$status"` returns the accumulated result to the shell.

The script checks directory links only; it does not check `/usr/local/bin`
links or links to individual files.

### Trace an example

For `name=rofi`, the script checks `~/.dotfiles/config/rofi` and then
`~/.config/rofi`. Suppose the latter contains a link to the former:

```text
~/.config/rofi -> /home/alex/.dotfiles/config/rofi
```

1. `-d` tests that the source resolves to a directory.
2. `-L` tests that the destination itself is a symbolic link, even if broken.
3. `$(readlink -e "$destiny")` runs `readlink` and substitutes its output into
   the comparison. The same resolution is performed for the source.
4. `[ "left" != "right" ]` is true when the resolved path strings differ.
5. If any branch sets `status=1`, later successful iterations do not reset it.
   `exit "$status"` returns the final result to the calling shell.

To display the exit status immediately after a check:

```bash
~/.dotfiles/bin/check-links.sh
printf 'Exit status: %s\n' "$?"
```

`$?` contains the exit status of the most recently executed command, so read
it before running an unrelated command. The checks are read-only, although
their results reflect the filesystem state at the time each command runs.
