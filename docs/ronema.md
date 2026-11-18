# `bin/ronema`

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
- `BASH_SOURCE[0]` is the path Bash used to invoke this script; it does not
  resolve a symbolic link to its final target. `dirname` gets its directory,
  `cd` enters it, and `pwd` saves that directory in `DIR`. When invoked through
  `/usr/local/bin/ronema`, `DIR` is normally `/usr/local/bin`, so the fallback
  configuration location matters.
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

### Follow the execution

1. At script load, `WIRELESS_INTERFACES=($(...))` and its Ethernet equivalent
   collect words printed by `nmcli | awk`. Bash command substitution runs the
   pipeline first; the unquoted result is then split into array elements and
   can undergo filename expansion. It is convenient for typical interface
   names, but not robust for arbitrary whitespace or wildcard characters.
2. `main` calls `initialization && rofi_menu`: the menu is only called if
   initialization succeeds. Initialization loads configuration and language
   variables, finds theme and icons, retrieves adapter product names, and
   refreshes network states.
3. `wireless_interface_state` and `ethernet_interface_state` build the global
   `OPTIONS` string. `\\n` sequences represent rows which `echo -e` later
   converts to newlines.
4. `rofi_menu` sends those rows to `rofi_cmd`, captures the chosen line in
   `SELECTION`, extracts an `SSID`, and calls `selection_action`.
5. `selection_action` matches fixed labels first. Its default branch attempts
   to interpret a selection as a Wi-Fi entry. Functions such as `scan`,
   `connect`, `vpn`, and `status` perform the selected operation.

### Function map

| Functions | Role |
| --- | --- |
| `initialization`, `main` | Load resources and enter the menu. |
| `wireless_interface_state`, `ethernet_interface_state` | Read adapter state and construct available actions. |
| `rofi_menu`, `rofi_cmd`, `selection_action` | Render a menu, return a selection, and route it. |
| `change_wireless_interface`, `scan`, `wifi_list` | Select an adapter, rescan, and format access points. |
| `change_wifi_state`, `change_wired_state`, `net_restart`, `disconnect` | Change radio, device, or networking state. |
| `connect`, `stored_connection`, `ssid_manual`, `ssid_hidden` | Request credentials or use saved profiles to connect. |
| `enter_passwword`, `enter_ssid`, `check_wifi_connected` | Collect values and disconnect the current connection if needed. The misspelling in the first name is present in the script. |
| `interface_status`, `status`, `vpn`, `more_options` | Display status and manage optional network actions. |
| `share_pass`, `gen_qrcode` | Display credentials and optionally write a Wi-Fi QR image. |
| `notification`, `manual_hidden` | Show optional notifications and the manual/hidden-network submenu. |

### Expand a pipeline

This representative pipeline is read-only:

```bash
nmcli device | awk '$2=="wifi" {print $1}'
```

`nmcli device` prints device rows. `|` feeds them to `awk`; `$2=="wifi"`
matches rows whose second whitespace-separated field is exactly `wifi`, and
`{print $1}` prints the first field. The single quotes ensure Bash does not
expand `$2` or `$1`: they belong to `awk`, not the shell.

For a second example, `nmcli -t -f GENERAL.CONNECTION dev show DEVICE |
cut -d ':' -f2` requests terse output with only the connection field, then
splits on `:` and prints field two. It is a simple parser, not a general parser
for escaped colons in arbitrary names.

### Safety and troubleshooting

The script parses human-readable `nmcli` output and English phrases including
`successfully activated`; locale, spacing, and unusual SSIDs can affect
parsing. Some values are expanded without quotes, so spaces or wildcard
characters may change argument splitting. Passwords are passed in command-line
arguments to `nmcli` in some flows and can be visible to other local processes.
The sharing function displays the Wi-Fi password, and QR codes can be written
to the configured `QRCODE_DIR` (currently `/tmp/`). Treat both as sensitive:
the image can remain after the menu closes.

For diagnostics, use read-only queries before selecting actions:

```bash
nmcli device status
nmcli --fields SSID,SECURITY,BARS device wifi list
```

The second command lists nearby networks and may trigger a scan depending on
NetworkManager's state. `nmcli` operations such as `con add`, `con modify`,
`con up`, `con down`, and `networking off` alter system network state.
