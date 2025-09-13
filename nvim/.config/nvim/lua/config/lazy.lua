--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                            LAZY.NVIM SETUP                             │
  │                                                                         │
  │ This file bootstraps and configures lazy.nvim, the plugin manager.     │
  │ It handles:                                                             │
  │ 1. Installing lazy.nvim if it's not present                            │
  │ 2. Setting up leader keys                                               │
  │ 3. Configuring plugin loading from lua/plugins/                        │
  │ 4. Loading our core configurations                                     │
  │                                                                         │
  │ This is the heart of the Neovim configuration system.                  │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                         BOOTSTRAP LAZY.NVIM                            │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Automatically install lazy.nvim if it's not already installed
-- This ensures your config works on any fresh Neovim installation

-- Path where lazy.nvim will be installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- Check if lazy.nvim is already installed
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  -- Not installed, so download it from GitHub
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone",
    "--filter=blob:none",     -- Shallow clone for faster download
    "--branch=stable",        -- Use stable branch
    lazyrepo,
    lazypath
  })

  -- Check if the git clone was successful
  if vim.v.shell_error ~= 0 then
    -- Show error message if clone failed
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar() -- Wait for user input
    os.exit(1)        -- Exit with error code
  end
end

-- Add lazy.nvim to Neovim's runtime path so we can require it
vim.opt.rtp:prepend(lazypath)

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                           LEADER KEYS                                  │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- IMPORTANT: These must be set BEFORE loading lazy.nvim
-- Otherwise, plugin keymaps might not use the correct leader key

-- Set leader key to Space (matches your VS Code configuration)
-- Leader key is used for custom commands: <leader>w = <Space>w
vim.g.mapleader = " "

-- Set local leader key to backslash
-- Local leader is typically used for filetype-specific commands
vim.g.maplocalleader = "\\"

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                        LAZY.NVIM CONFIGURATION                         │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Configure and start lazy.nvim
require("lazy").setup({
  -- ═══════════════════════════════════════════════════════════════════════
  --                              PLUGIN SPEC
  -- ═══════════════════════════════════════════════════════════════════════
  spec = {
    -- Import all plugin files from lua/plugins/ directory
    -- Each .lua file in that directory should return a plugin configuration
    { import = "plugins" },
  },

  -- ═══════════════════════════════════════════════════════════════════════
  --                           LAZY.NVIM OPTIONS
  -- ═══════════════════════════════════════════════════════════════════════

  -- Installation settings
  install = {
    -- Colorscheme to use during plugin installation
    -- This prevents errors if plugins try to use colorschemes before they're loaded
    colorscheme = { "habamax" }
  },

  -- Plugin update checker
  checker = {
    enabled = true,  -- Automatically check for plugin updates
    -- notify = false,  -- Uncomment to disable update notifications
  },

  -- Other useful options you can configure:
  -- ui = {
  --   border = "rounded",     -- Rounded borders for lazy.nvim windows
  --   size = { width = 0.8, height = 0.8 }, -- Window size
  -- },
  -- performance = {
  --   rtp = {
  --     disabled_plugins = {  -- Disable unused built-in plugins for better performance
  --       "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
  --     },
  --   },
  -- },
})

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                        LOAD CORE CONFIGURATIONS                        │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Load our core configuration files
-- These are loaded AFTER lazy.nvim setup so plugins are available

-- Load Vim options (line numbers, indentation, search behavior, etc.)
require("config.options")

-- Load custom keymaps (space-leader workflow matching VS Code patterns)
require("config.keymaps")

