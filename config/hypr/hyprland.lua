-- Detect automatically resolution and scale from monitor
-- 1st Display
hl.monitor({
	output = "DP-3",
	mode = "1920x1080@165",
	position = "0x0",
	scale = 1,
})

-- 2nd Display
hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@75",
	position = "1920x0",
	scale = 1,
})

-- Default
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = 1,
})

hl.config({
	general = {
		gaps_in = 6,
		gaps_out = { left = 10, right = 10, top = 4, bottom = 4 },
		border_size = 2,
		layout = "dwindle",
		resize_on_border = true,
		col = {
			active_border = "rgba(777c84ff)",
			inactive_border = "rgba(373a40ff)",
		},
	},
	dwindle = {
		preserve_split = true,
	},
	group = {
		col = {
			border_active = "rgba(777c84ff)",
			border_inactive = "rgba(373a40ff)",
			border_locked_active = "rgba(777c84ff)",
			border_locked_inactive = "rgba(373a40ff)",
		},
		groupbar = {
			font_family = "JetBrainsMono Nerd Font",
			font_size = 12,
			col = {
				active = "rgba(41454aff)",
				inactive = "rgba(23262cff)",
			},
		},
	},
	decoration = {
		rounding = 12,
		-- Like border radius
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 1.0,
		shadow = {
			enabled = true,
			range = 8,
		},
		blur = {
			enabled = true,
			size = 6,
			passes = 2,
		},
	},
	input = {
		-- Switch between US and Latin American layouts with Alt + Shift
		kb_layout = "us,latam",
		kb_options = "grp:alt_shift_toggle",
		follow_mouse = 1,
	},
	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
	},
})

-- Hyperland | On start
hl.on("hyprland.start", function()
	hl.exec_cmd("waybar")
	hl.exec_cmd("swaybg -i ~/Pictures/Wallpapers/wallpaper-1.png -m fill")
	hl.exec_cmd("swaync")
end)

local mod = "SUPER"
local magic = "CTRL + SHIFT"
local mod_magic = "SUPER + SHIFT"

-- Open Terminal
hl.bind(magic .. " + T", hl.dsp.exec_cmd("ghostty"))

-- Lock Screen
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))

-- Show search bar
hl.bind("SUPER + R", hl.dsp.exec_cmd("rofi -show drun -show-icons"))

-- Open the window switcher
hl.bind(
	"ALT + TAB",
	hl.dsp.exec_cmd("rofi -show window -show-icons -theme ~/.config/graphite-tab-switcher/window-switcher.rasi")
)

-- Close window
hl.bind(mod .. " + C", hl.dsp.window.close())

-- Toggle between horizontal and vertical split
hl.bind(mod .. " + T", hl.dsp.layout("togglesplit"))

-- Screenshot
hl.bind(mod .. " + S", hl.dsp.exec_cmd("screenshot.sh"))

-- Display
for i = 1, 9 do
	-- Change workspace -> SUPER + <number>
	hl.bind(mod .. " + " .. i, hl.dsp.focus({ workspace = i }))

	-- Change window to another workspace
	hl.bind(
		mod_magic .. " + " .. i,
		hl.dsp.window.move({
			workspace = i,
			follow = false, -- Stay on current desktop.
		})
	)
end

-- Toggle fullscreen
hl.bind(
	mod .. " + F",
	hl.dsp.window.fullscreen({
		mode = "fullscreen",
		action = "toggle",
	})
)

hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))

-- Move windows with Super + left click
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), {
	mouse = true,
})

-- Move windows with Super + right click
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), {
	mouse = true,
})

hl.bind(
	mod_magic .. " + N",
	hl.dsp.window.move({
		workspace = "special:minimized",
		follow = false,
	})
)

hl.bind(mod .. " + N", hl.dsp.workspace.toggle_special("minimized"))

hl.bind(mod .. " + B", hl.dsp.exec_cmd("swaync-client -t"))

-- Move windows in the tiled layout
hl.bind(mod .. " + SHIFT + LEFT", hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + RIGHT", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + UP", hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + DOWN", hl.dsp.window.move({ direction = "down" }))

hl.bind(mod .. " + CTRL + UP", hl.dsp.window.alter_zorder({ mode = "top" }))

-- Create or dissolve a group for the focused window
hl.bind(mod .. " + G", hl.dsp.group.toggle())

-- Switch between windows in the active group
hl.bind(mod .. " + TAB", hl.dsp.group.next())
hl.bind(mod .. " + SHIFT + TAB", hl.dsp.group.prev())

-- Remove the focused window from its group
hl.bind(mod .. " + SHIFT + G", hl.dsp.window.move({ out_of_group = true }))

-- Move the focused window into a group to its left or right
hl.bind(mod .. " + ALT + LEFT", hl.dsp.window.move({ into_group = "l" }))
hl.bind(mod .. " + ALT + RIGHT", hl.dsp.window.move({ into_group = "r" }))
