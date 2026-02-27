-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- Background color: managed by switch-theme script via ~/.config/wezterm/background
local bg_file = wezterm.home_dir .. "/.config/wezterm/background"
wezterm.add_to_config_reload_watch_list(bg_file)
local f = io.open(bg_file, "r")
if f then
  local color = f:read("*l")
  f:close()
  if color and color ~= "" then
    config.colors = { background = color }
  end
end

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

local is_windows = wezterm.target_triple == "x86_64-pc-windows-msvc"
local hide_action = is_windows and wezterm.action.Hide or wezterm.action.HideApplication

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
    action = hide_action,
  },
  {
    key = 'L',
    mods = 'CTRL|SHIFT',
    action = wezterm.action.SendString("\x1b[108;6u"),
  },
  {
    key = 'D',
    mods = 'CTRL|SHIFT|ALT',
    action = wezterm.action.ShowDebugOverlay,
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
	-- Remove bottom padding to eliminate blank line below tmux status bar in WSL2
	config.window_padding = { bottom = 0 }

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

