# `bin/lid-monitor.sh`

Moves workspaces between the laptop panel (`eDP-1`) and the external display
(`HDMI-A-1`) when Hyprland reports lid-switch events. The bindings are in
`config/hypr/hyprland.lua`.

Create the link used by the Hyprland bindings (adjust the source path if the
repository is elsewhere):

```bash
sudo ln -s "$HOME/.dotfiles/bin/lid-monitor.sh" /usr/local/bin/lid-monitor.sh
```

Then reload Hyprland with `hyprctl reload`. To test manually:

```bash
/usr/local/bin/lid-monitor.sh close
/usr/local/bin/lid-monitor.sh open
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
  specific to the current user. The `/tmp` fallback may persist after logout.
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
fails with a nonzero process status, `set -e` stops the script and leaves the
state file for diagnosis. Some `hyprctl` errors may instead be printed as text
with a successful process status; the script does not check the response text.

### Walkthrough with an example

Suppose workspaces `1` and `3` are on `eDP-1`, and workspace `2` is on
`HDMI-A-1`. When Hyprland invokes the script with `close`:

1. `[[ -e "$state_file" ]] && exit 0` avoids overwriting an existing list. If
   the test is false, `&&` skips `exit` and execution continues.
2. `monitor_exists "HDMI-A-1" || exit 0` returns early if no external display
   is reported. The right side of `||` executes only on failure.
3. `.[] | select(.monitor == "eDP-1") | .id` expands the JSON array into
   objects, keeps the ones on the laptop and extracts their IDs. The result is
   `1` and `3` on separate lines.
4. `printf '%s\n' "$workspaces" >"$state_file"` creates or truncates the state
   file and writes the list. `>` redirects standard output to a file.
5. Each loop iteration invokes the Lua dispatcher. Workspace `2` is not moved
   because it was already on the external monitor.
6. On `open`, the saved IDs are moved back and the state file is removed.

The IDs are saved *before* moving. If interrupted midway, the file contains
the complete original list. There is no lock against simultaneous invocations.
The fixed `sleep 1` cannot guarantee that the panel is ready. Special workspace
IDs have not been separately validated. The script moves workspaces; it does
not disable the internal display.

Inspect the inputs without moving anything:

```bash
hyprctl -j monitors | jq '.[].name'
hyprctl -j workspaces | jq '.[] | {id, name, monitor}'
```

Manual `close` and `open` calls really move workspaces. If a state file remains,
inspect it before retrying: `close` deliberately skips work while it exists.
