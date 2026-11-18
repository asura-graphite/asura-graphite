# `config/graphite-power/power.sh`

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

### Trace the menu

`LOCK="…"` and the other assignments store the text shown to the user. The
quoted `"$LOCK"` arguments preserve the spaces and icon as a single argument.
`printf '%s\n'` formats each argument as a string (`%s`) followed by a newline
(`\n`). The backslash at the end of a physical line continues the same shell
command on the next line.

The `|` passes the four lines to Rofi. `choice=$(...)` captures the selected
line and removes its trailing newline. If Rofi exits unsuccessfully,
`|| exit 0` ends the script, so closing the menu does not trigger an action.
`case "$choice" in … esac` compares that exact line with each variable; `;;`
ends a branch. An unrecognized selection matches none and does nothing.

For an educational menu with no power actions, try:

```bash
printf '%s\n' 'First' 'Second' | rofi -dmenu -i
```

Selecting an entry prints it to the terminal. **Do not run** the reboot or
poweroff commands just to test them: they request immediate system actions.
The script uses legacy `hyprctl dispatch exit`; its compatibility with a Lua
configuration is not established here and should be tested separately.
