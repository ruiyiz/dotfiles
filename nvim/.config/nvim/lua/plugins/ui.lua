--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                             UI PLUGINS                                  │
  │                                                                         │
  │ This file contains plugins that enhance Neovim's visual appearance:    │
  │ - Colorscheme (catppuccin) for pleasant colors                         │
  │ - Statusline (lualine) for informative bottom bar                      │
  │                                                                         │
  │ These make Neovim look modern and provide useful visual feedback.      │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- mini.icons: icon provider used by which-key (and others) as a devicons alternative
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {},
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                            COLORSCHEME                                  │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- Catppuccin colorscheme - modern, warm colors that are easy on the eyes
    "catppuccin/nvim",

    -- Use "catppuccin" as the name when calling the colorscheme
    name = "catppuccin",

    -- Load this plugin first (high priority) since other plugins depend on colors
    priority = 1000,

    -- Configuration options for catppuccin
    opts = {
      -- Choose the flavor: "latte" (light), "frappe" (mid), "macchiato" (dark), "mocha" (darkest)
      flavour = "mocha",

      -- Automatic background detection
      background = {
        light = "latte", -- Use latte when Neovim is in light mode
        dark = "mocha",  -- Use mocha when Neovim is in dark mode
      },

      -- Set to true for transparent background (uses terminal background)
      transparent_background = false,

      -- Enable integrations with other plugins for consistent theming
      integrations = {
        treesitter = true,               -- Style syntax highlighting
        telescope = { enabled = true },  -- Style telescope picker
        which_key = true,               -- Style which-key popup
        gitsigns = true,                -- Style git signs in gutter
        bufferline = true,              -- Style bufferline tabs
        cmp = true,                     -- Style completion popup
        noice = true,                   -- Style noice cmdline popup
        -- Add more integrations as you install plugins:
        -- lsp_trouble = true,          -- For diagnostics
      },
    },

    -- Configuration function (runs after plugin loads)
    config = function(_, opts)
      -- Setup catppuccin with our options
      require("catppuccin").setup(opts)
      -- Apply the colorscheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                             STATUSLINE                                  │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- Lualine provides a informative statusline at the bottom of Neovim
    "nvim-lualine/lualine.nvim",

    -- Requires devicons for file type icons (optional but nice)
    dependencies = { "nvim-tree/nvim-web-devicons" },

    -- Configuration
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,      -- Show file type and git icons
          theme = "catppuccin",      -- Match our colorscheme

          -- Separators between components and sections
          component_separators = { left = "", right = "" },  -- Simple separators
          section_separators = { left = "", right = "" },    -- Rounded section separators
        },

        -- ═══════════════════════════════════════════════════════════════════
        --                       ACTIVE WINDOW SECTIONS
        -- ═══════════════════════════════════════════════════════════════════
        -- Layout: |a|b|c|          |x|y|z|
        sections = {
          lualine_a = { "mode" },                    -- Current mode (NORMAL, INSERT, etc.)
          lualine_b = { "branch", "diff", "diagnostics" }, -- Git branch, changes, LSP diagnostics
          lualine_c = { "filename" },                -- Current file name
          lualine_x = { "encoding", "fileformat", "filetype" }, -- File encoding, format, type
          lualine_y = { "progress" },                -- File position percentage
          lualine_z = { "location" },                -- Line and column number
        },

        -- ═══════════════════════════════════════════════════════════════════
        --                      INACTIVE WINDOW SECTIONS
        -- ═══════════════════════════════════════════════════════════════════
        -- Simpler statusline for windows that don't have focus
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" }, -- Just show filename
          lualine_x = { "location" }, -- Just show position
          lualine_y = {},
          lualine_z = {},
        },

        -- Other options you can configure:
        -- tabline = {},    -- Top line showing tabs/buffers
        -- extensions = {}, -- Special handling for filetypes like NvimTree
      })
    end,
  },
}