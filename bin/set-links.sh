#!/usr/bin/env bash

for name in swaync ronema waybar ghostty graphite-power graphite-tab-switcher hypr rofi wlogout satty; do
	origin="$HOME/.dotfiles/config/$name"
	destiny="$HOME/.config/$name"
	
	if [ ! -d "$origin" ]; then
		echo "Origin with name $origin does not exist."
	elif [ -L "$destiny" ]; then
		ln -sfnT "$origin" "$destiny"
		echo "Updated ✅: $origin -> $destiny"
	elif [ ! -e "$destiny" ]; then
		ln -sf "$origin" "$destiny"
		echo "Created ✅ $origin -> $destiny"
	else
		echo "Destiny exists and is not a link: $destiny"
	fi
done
