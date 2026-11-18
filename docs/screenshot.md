# `config/satty/screenshot.sh`

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

### Data flow and Bash syntax

```text
mouse selection → slurp → geometry string → grim → PPM bytes → Satty
```

`geometry="$(slurp -c '#ff0000ff')"` uses command substitution: Bash runs
`slurp`, captures its standard output, removes trailing newlines, and assigns
the result to `geometry`. A typical value might be `100,200 800x600`.
`"$geometry"` is quoted so that the space inside the value remains part of one
argument to `grim`.

The vertical bar connects the standard output of `grim` to standard input of
Flatpak/Satty. The `-` at the end of the `grim` command and the `-` after
`--filename` mean stdout and stdin respectively, as interpreted by those
programs; they are not generic Bash syntax. `pipefail` means failure of either
program can cause the pipeline to fail. The `|| exit 0` applies to the region
selection: a failed selection, including cancellation, stops before capturing.

To inspect the selector independently, run `slurp` and draw a rectangle; it
prints geometry rather than capturing an image. To test the full script, run
the command above in a Wayland session and select a region. This opens Satty
and captures the selected screen content, so avoid displaying private data.
