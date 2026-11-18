#!/usr/bin/env bash

# Power menu

LOCK="󰌾  Bloquear"
LOGOUT="󰍃  Salir"
REBOOT="󰜉  Reiniciar"
SHUTDOWN="󰐥  Apagar"

choice=$(printf '%s\n' \
    "$LOCK" \
    "$LOGOUT" \
    "$REBOOT" \
    "$SHUTDOWN" |
    rofi -dmenu -i \
        -theme "$HOME/.config/graphite-power/graphite-power.rasi" \
        -theme-str 'window { width: 280px; }' \
        -theme-str 'listview { lines: 4; }' \
        -theme-str 'element-text { font: "JetBrainsMono Nerd Font 13"; }'
) || exit 0

case "$choice" in
    "$LOCK")     hyprlock ;;
    "$LOGOUT")   hyprctl dispatch exit ;;
    "$REBOOT")   systemctl reboot ;;
    "$SHUTDOWN") systemctl poweroff ;;
esac
