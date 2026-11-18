# `bin/set-links.sh`

Creates or updates symbolic links for the repository's configuration
directories under `~/.config`.

```bash
~/.dotfiles/bin/set-links.sh
```

There are no command-line options. Edit the `for name in …` list to choose
which configuration directories are managed.

### Commands and options

- `#!/usr/bin/env bash` selects Bash from `PATH`.
- `for name in …; do … done` repeats the link logic for each listed
  configuration name.
- `$HOME` refers to the current user's home directory. `origin` is the source
  directory in `~/.dotfiles/config`; `destiny` is its target in `~/.config`.
- `[ ! -d "$origin" ]` checks that the source exists and is a directory.
- `[ -L "$destiny" ]` checks whether the target is already a symbolic link.
- `ln -sfnT "$origin" "$destiny"` updates an existing link:
  - `-s`: create a symbolic rather than hard link.
  - `-f`: replace an existing destination.
  - `-n`: treat a destination symlink to a directory as a link, not as a
    directory to follow.
  - `-T`: treat the destination as a normal path, not as a directory.
- `[ ! -e "$destiny" ]` checks whether no destination exists. `ln -sf` creates
  a symbolic link in that case; `-f` replaces a conflict if one appears.
- `echo` reports whether a link was created, updated, or skipped.

The script deliberately does not replace an existing real directory or file:
it prints a warning instead. Back up or move that destination yourself before
rerunning the script. It links directories in `config/`; it does not install
standalone commands from `bin/` into `/usr/local/bin`.

### Walkthrough: one entry

For `name=rofi`, the two assignments expand to:

```text
origin=/home/alex/.dotfiles/config/rofi
destiny=/home/alex/.config/rofi
```

The order of the branches matters:

1. A missing source is reported; nothing is created.
2. An existing symlink (including a dangling symlink) is replaced using
   `ln -sfnT`.
3. A missing destination is created with `ln -sf`.
4. Any other existing destination is left untouched.

Quotes around `"$origin"` and `"$destiny"` preserve spaces as part of one
argument. `$name` inside a double-quoted string expands the variable; assigning
`origin="..."` does not execute a command. `!` negates a test's result, and
`elif` starts the next conditional branch.

To inspect links without changing them, use:

```bash
ls -ld ~/.config/rofi
readlink ~/.config/rofi
readlink -e ~/.config/rofi
```

`readlink` prints the stored target; `readlink -e` resolves it to an existing
absolute path. A relative link target is resolved relative to the directory
containing the link, not the directory from which `ln` was run.

### Limitations

The script expects `~/.config` to exist and assumes the repository is at
`~/.dotfiles`. It does not use `set -e` or explicitly test whether each `ln`
succeeded before printing its success message. A failed link operation can
therefore be followed by a misleading message. `ln -T` is a GNU option.
