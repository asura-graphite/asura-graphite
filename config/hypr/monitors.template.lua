-- Copy this file to ~/.config/hypr/monitors.local.lua and edit it per machine.
-- Find output names and available modes with: hyprctl monitors all
-- Positions are XxY in logical pixels. The origin 0x0 is the top-left of
-- the first display. To place another display to its right, use its logical
-- width as the next X coordinate: resolution width / scale (1920 / 1 = 1920).
-- Adjust coordinates for your own resolutions, scales and physical layout.
-- "preferred" selects the display's preferred mode; "auto" places it
-- automatically. The final empty output is a fallback for other displays.

hl.monitor({
	output = "DP-3", -- Replace with your first display's output name.
	mode = "preferred",
	position = "0x0",
	scale = 1,
})

hl.monitor({
	output = "HDMI-A-1", -- Example: 1920-wide first display, scale 1.
	mode = "preferred",
	position = "1920x0",
	scale = 1,
})

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })
