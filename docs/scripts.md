# Script reference

This guide explains the repository's shell scripts, how to run them, what their
commands and important options do, and why those choices are used. It is an
educational companion; it does not replace each command's manual page.

Run commands from the repository root unless a section says otherwise.

## `bin/lid-monitor.sh`

Moves workspaces between the laptop panel (`eDP-1`) and the external display
(`HDMI-A-1`) when Hyprland reports lid-switch events. The bindings are in
`config/hypr/hyprland.lua`.

```bash
~/.dotfiles/bin/lid-monitor.sh close
~/.dotfiles/bin/lid-monitor.sh open
```

The only accepted arguments are `close` and `open`. The first saves the IDs of
workspaces on `eDP-1` and moves them to `HDMI-A-1`; the second moves the saved
workspaces back after a one-second delay.

### Commands and options

- `#!/usr/bin/env bash` asks `env` to find Bash through `PATH`. This avoids
  hard-coding Bash's installation path.
- `set -euo pipefail` enables three safety checks:
  - `-e`: stop when a command fails.
  - `-u`: treat use of an unset variable as an error.
  - `pipefail`: make a pipeline fail if any command in it fails, not only its
    last command.
- `${1:-}` reads the first argument, or uses an empty string if it was omitted.
- `${XDG_RUNTIME_DIR:-/tmp}` chooses the session's runtime directory when set,
  with `/tmp` as a fallback. `${UID}` makes the temporary state filename
  specific to the current user.
- `hyprctl -j monitors` requests monitor information as JSON. `-j` means JSON.
- `jq -e --arg name "$1" '…'` checks whether the requested monitor appears in
  that JSON. `--arg` safely passes a shell value into the jq expression; `-e`
  returns a failing exit status if there is no match.
- `hyprctl -j workspaces` lists workspaces. `jq -r` emits raw text rather than
  JSON strings, selecting workspaces whose `.monitor` is `eDP-1` and printing
  their numeric `.id`.
- `umask 077` makes the saved state file readable and writable only by its
  owner. The file contains workspace IDs, not passwords or other credentials.
- `printf '%s\n'` writes one workspace ID per line. It is used instead of
  `echo` because `printf` handles arbitrary text and newlines consistently.
- `while IFS= read -r workspace` reads each saved ID without trimming spaces or
  interpreting backslashes. The here-string (`<<<`) supplies the IDs collected
  during the close action; input redirection (`<`) reads them back on open.
- `hyprctl dispatch "hl.dsp.workspace.move({ workspace = …, monitor = … })"`
  invokes Hyprland's Lua dispatcher API. This form is required by this
  repository's Hyprland 0.57 Lua configuration; the older
  `moveworkspacetomonitor WORKSPACE MONITOR` syntax is not valid here.
- `sleep 1` gives Hyprland a moment to bring `eDP-1` back after the lid opens.
- `rm -f` removes the temporary state file. `-f` avoids an error if it has
  already disappeared.
- `case` accepts only `close` and `open`; any other or missing argument exits
  with status `2`.

The monitor names are machine-specific. Change both the script and the matching
Hyprland bindings if your outputs have different names. If a workspace move
fails, `set -e` stops the script and leaves the state file for diagnosis.

## `bin/set-links.sh`

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

## `bin/check-links.sh`

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

## `bin/ronema`

Ronema is the interactive Rofi front end for NetworkManager. Run it with:

```bash
ronema
# or
~/.dotfiles/bin/ronema
```

It has no general command-line options. Its language, theme, labels, and
behavior are configured by `config/ronema/ronema.conf`,
`config/ronema/languages/`, and `config/ronema/themes/`.

### Startup and shell structure

- `#!/usr/bin/env bash` runs the script with Bash.
- `BASH_SOURCE[0]` identifies this script even when it is invoked through a
  symbolic link. `dirname` gets its directory, `cd` enters it, and `pwd` saves
  the canonical working directory in `DIR`. This lets Ronema find files
  alongside its own script.
- `nmcli device` asks NetworkManager for device status. `awk '$2=="wifi" …'`
  and `awk '$2=="ethernet" …'` select wireless and wired interface names from
  the output.
- Bash arrays (`WIRELESS_INTERFACES`, `WIRED_INTERFACES`) keep interface names
  available to later functions. Product-name arrays are filled from
  `nmcli -f general.product device show DEVICE`; `-f` limits output to the
  requested field.
- `function name() { … }` defines a Bash function. `main` is called at the
  bottom of the file and starts initialization followed by the main menu.
- `source FILE` runs a configuration or language file in the current shell so
  its variables remain available. Ronema first looks beside the script, then
  under `${XDG_CONFIG_HOME:-$HOME/.config}/ronema/`; `${VAR:-fallback}` uses
  the fallback when the variable is unset or empty.
- `&&` runs the next command only after success; `||` runs its right-hand
  command after failure. Braces group command lists without starting a
  subshell.

### Menus and text processing

- `rofi -dmenu -i` displays supplied lines as an interactive menu:
  - `-dmenu`: read menu entries from standard input.
  - `-i`: case-insensitive matching.
  - `-location`, `-xoffset`, `-yoffset`: place the menu on screen.
  - `-theme`: choose a Rasi theme.
  - `-theme-str`: apply inline theme overrides, such as dynamic width or prompt
    text.
  - `-password`: request concealed password input.
  - `-a`: mark selected rows as active.
- `echo -e` builds newline-separated menu text. `printf` is generally safer for
  arbitrary data; here the script relies on its configured labels containing
  `\n` sequences.
- `awk` extracts columns and filters rows. `grep` matches interface state,
  connection names, or command output; `-c` counts matches and `-oP` prints
  Perl-compatible regular-expression matches only.
- `sed` rewrites menu text, signal bars, or connection names. `-F` in `awk`
  selects a field separator.
- `sort -n` sorts numerically; `tail -1` picks the longest-width measurement
  after sorting. `head -1` picks the first result.
- `local` limits a variable to a function. `local -n` creates a Bash nameref,
  allowing `interface_status` to inspect the arrays whose names it receives.
- `case … esac` routes a Rofi selection to the appropriate action function.
- `[[ … ]]` performs Bash conditional tests; `=~` tests a regular expression;
  `-n` and `-z` test for non-empty and empty strings; `-x` checks whether a
  command is executable.

### NetworkManager, notifications, and optional tools

- `nmcli` is NetworkManager's command-line interface:
  - `device status` and `device show` inspect adapters and their state.
  - `device wifi list [--rescan yes]` lists visible networks; `--rescan yes`
    requests a fresh scan.
  - `radio wifi on|off` toggles Wi-Fi radio state.
  - `device connect|disconnect` controls a wired adapter.
  - `device wifi connect SSID [password PASSWORD] [ifname DEVICE]` connects to
    a network; `ifname` selects the adapter.
  - `con up|down id NAME` activates or deactivates a saved connection.
  - `con add` and `con modify` create or update a saved Wi-Fi connection.
  - `-t` requests terse output; `-g` selects fields for terse output; `--fields`
    chooses fields for regular output.
- `notify-send -r 5 -u normal` replaces notification ID `5` and sets normal
  urgency. The `-i` option supplies an icon. Notifications are conditional on
  the Ronema configuration and `notify-send` being installed.
- `sleep 2` gives Wi-Fi a moment to become available after enabling it.
- `qrencode -t png -o FILE -l H -s 25 -m 2 --dpi=192 TEXT` writes a high-error-
  correction PNG QR code to `FILE`; `-t` chooses image type, `-o` output path,
  `-l` error correction, `-s` module size, `-m` margin, and `--dpi` image
  resolution. This is optional and used for sharing Wi-Fi details.
- `nm-connection-editor` opens NetworkManager's graphical editor when
  available.
- `cut -d ':' -f2` splits at `:` and selects the second field.
- `ip4.address` and other `nmcli -g` fields request a specific connection
  property.

Because Ronema invokes commands that change network state, connecting,
disconnecting, enabling radios, or editing saved connections takes effect
immediately. The menu itself does not run as root; NetworkManager authorizes
permitted operations.

## `config/graphite-power/power.sh`

Shows a four-item Rofi menu for locking, logging out, rebooting, or shutting
down. Waybar launches it from the power module.

```bash
~/.config/graphite-power/power.sh
```

It has no options. Pressing Escape or cancelling Rofi exits without taking
action.

### Commands and options

- `printf '%s\n'` supplies one menu item per line.
- `rofi -dmenu -i` displays those choices; `-dmenu` reads standard input and
  `-i` enables case-insensitive matching.
- `-theme` loads the Graphite theme.
- `-theme-str` overrides the window width, number of visible rows, and font for
  this invocation only.
- `|| exit 0` treats Rofi cancellation as a normal, harmless exit.
- `case "$choice" in … esac` selects the action:
  - `hyprlock` starts the lock screen.
  - `hyprctl dispatch exit` asks Hyprland to end the current compositor
    session.
  - `systemctl reboot` requests a system reboot.
  - `systemctl poweroff` requests a system shutdown.

The last two commands are intentionally destructive system actions and are
only run after the user selects the corresponding menu item.

## `config/satty/screenshot.sh`

Captures a selected screen region and opens the result in Satty. The Hyprland
shortcut is `SUPER + S`; the command is `screenshot.sh` when the script is
available on `PATH`.

```bash
~/.config/satty/screenshot.sh
```

It takes no options.

### Commands and options

- `#!/bin/bash` runs the script with Bash using that fixed path.
- `set -euo pipefail` stops on command errors, unset variables, and failed
  pipeline components.
- `slurp -c '#ff0000ff'` lets the user draw a screen region. `-c` sets the
  selection border color to opaque red. If selection is cancelled, `|| exit 0`
  exits successfully instead of reporting an error.
- `grim -g "$geometry" -t ppm -` captures the selected geometry:
  - `-g` supplies the rectangle returned by `slurp`.
  - `-t ppm` encodes the capture as portable pixmap.
  - `-` writes the image to standard output instead of a temporary file.
- The pipe (`|`) sends that image directly to
  `flatpak run org.satty.Satty --filename -`.
- `flatpak run` launches the installed Flatpak application.
  `--filename -` tells Satty to read the image from standard input. Streaming
  avoids writing a separate screenshot file before editing.

Requirements include `slurp`, `grim`, Flatpak, and the `org.satty.Satty`
application.
