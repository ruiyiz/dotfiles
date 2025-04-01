-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

-- Set font
config.font = wezterm.font("JetBrainsMono Nerd Font")

-- Set font size based on the operating system
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- Windows: 14pt font size
	config.font_size = 14
elseif wezterm.target_triple == "x86_64-apple-darwin" or wezterm.target_triple == "aarch64-apple-darwin" then
	-- macOS (Intel or Apple Silicon): 17pt font size
	config.font_size = 17
else
	-- Default for other platforms
	config.font_size = 16
end

-- Set initial window dimensions
config.initial_cols = 120
config.initial_rows = 60

config.keys = {
	-- Turn off the default CMD-m Hide action, allowing CMD-m to
	-- be potentially recognized and handled by the tab
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
}

-- Check if we're running on Windows and set WSL as default domain if so
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_domain = "WSL:Ubuntu-24.04"
end

-- and finally, return the configuration to wezterm
return config

