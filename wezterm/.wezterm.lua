-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
-- config.color_scheme = 'AdventureTime'

-- Set font
config.font = wezterm.font("JetBrainsMono Nerd Font Mono")

-- Set font size based on the operating system
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- Windows: 14pt font size
	config.font_size = 13
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

config.hide_tab_bar_if_only_one_tab = true

config.keys = {-- Turn off the default CMD-m Hide action, allowing CMD-m to
	-- be potentially recognized and handled by the tab
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment
	},
  {
    key = 'F11',
    mods = 'NONE',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = 'F12',
    mods = 'NONE',
    action = wezterm.action.Hide,
  },
  {
		key="Enter",
		mods="SHIFT",
		action=wezterm.action{SendString="\x1b\r"}
	},
}

-- On Windows, pass Alt+Arrow through to tmux for pane navigation
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	for _, arrow in ipairs({"LeftArrow", "RightArrow", "UpArrow", "DownArrow"}) do
		table.insert(config.keys, {
			key = arrow,
			mods = "ALT",
			action = wezterm.action.SendKey({ key = arrow, mods = "ALT" }),
		})
	end
end

-- Check if we're running on Windows and set WSL as default domain if so
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = {"wsl.exe", "--distribution", "Ubuntu", "--cd", "~"}

	-- Configure launch menu with PowerShell and Git Bash
	config.launch_menu = {
		{
			label = "PowerShell",
			args = {"powershell.exe", "-NoLogo"},
		},
		{
			label = "Git Bash",
			args = {"C:\\Program Files\\Git\\bin\\bash.exe"},
		},
		{
			label = "WSL Ubuntu",
			args = {"wsl.exe", "--distribution", "Ubuntu"},
		},
	}
end

-- and finally, return the configuration to wezterm
return config

