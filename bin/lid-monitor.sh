#!/usr/bin/env bash

# Stop on errors, unset variables, and failures inside pipelines.
set -euo pipefail

# The caller passes "close" or "open" as the first argument.
action="${1:-}"
case "$action" in
    close|open) ;;
    *) exit 2 ;;
esac

# Two lines: laptop panel and external output. No local file means disabled.
config_file="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/lid-monitor.local.conf"
[[ -f "$config_file" ]] || exit 0
mapfile -t outputs <"$config_file"
internal="${outputs[0]:-}"
external="${outputs[1]:-}"
# Restrict names before inserting them into a Lua dispatcher expression.
[[ "$internal" =~ ^[a-zA-Z0-9._-]+$ && "$external" =~ ^[a-zA-Z0-9._-]+$ && "$internal" != "$external" ]] || exit 1
# Keep the workspace IDs private and available only for this login session.
state_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-lid-workspaces-${UID}"

# Return success only when the requested monitor is currently connected.
monitor_exists() {
    hyprctl -j monitors | jq -e --arg name "$1" '.[] | select(.name == $name)' >/dev/null
}

# Move a workspace using the Lua dispatcher API required by Hyprland 0.55+.
move_workspace() {
    hyprctl dispatch "hl.dsp.workspace.move({ workspace = $1, monitor = \"$2\" })"
}

case "$action" in
    close)
        # Avoid overwriting the saved list if the close event fires more than once.
        [[ -e "$state_file" ]] && exit 0
        # Nothing can be moved if the external monitor is disconnected.
        monitor_exists "$external" || exit 0

        # Save the workspaces currently on the laptop display before moving them.
        workspaces="$(hyprctl -j workspaces | jq -r --arg monitor "$internal" '.[] | select(.monitor == $monitor) | .id')"
        [[ -n "$workspaces" ]] || exit 0

        # Restrict access because this file is runtime state for this user only.
        umask 077
        printf '%s\n' "$workspaces" >"$state_file"
        while IFS= read -r workspace; do
            [[ -n "$workspace" ]] || continue
            move_workspace "$workspace" "$external"
        done <<<"$workspaces"
        ;;
    open)
        # There is nothing to restore if no close event saved any workspaces.
        [[ -f "$state_file" ]] || exit 0
        # Give Hyprland time to re-enable the laptop display after the lid opens.
        sleep 1
        monitor_exists "$internal" || exit 0

        while IFS= read -r workspace; do
            [[ -n "$workspace" ]] || continue
            move_workspace "$workspace" "$internal"
        done <"$state_file"
        rm -f "$state_file"
        ;;
    *)
        exit 2
        ;;
esac
