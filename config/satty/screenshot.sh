#!/bin/bash

set -euo pipefail

# Select a screen region and handle cancellation.
geometry="$(slurp -c '#ff0000ff')" || exit 0

# Capture the region and send it to Satty.
grim -g "$geometry" -t ppm - |
    flatpak run org.satty.Satty --filename -

