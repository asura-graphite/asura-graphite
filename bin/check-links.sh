#!/usr/bin/env bash

status=0

for name in swaync ronema waybar ghostty graphite-power graphite-tab-switcher hypr rofi wlogout satty; do
    origin="$HOME/.dotfiles/config/$name"
    destiny="$HOME/.config/$name"

    if [ ! -d "$origin" ]; then
        echo "ERROR ❌: Origin does not exist: $origin"
        status=1
    elif [ ! -L "$destiny" ]; then
        echo "ERROR ❌: Destination is not a symbolic link: $destiny"
        status=1
    elif [ "$(readlink -e "$destiny")" != "$(readlink -e "$origin")" ]; then
        echo "ERROR ❌: Link is broken or points elsewhere: $destiny"
        status=1
    else
        echo "OK ✅: $destiny -> $origin"
    fi
done

exit "$status"
