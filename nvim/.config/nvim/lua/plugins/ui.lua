--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                             UI PLUGINS                                  │
  │                                                                         │
  │ This file contains plugins that enhance Neovim's visual appearance:    │
  │ - Colorschemes (catppuccin, tokyonight, kanagawa, oxocarbon, gruvbox)  │
  │ - Themery: persistent theme switcher (<leader>ft)                       │
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
  -- │                            COLORSCHEMES                                  │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = true,
    opts = {
      flavour = "mocha",
      background = { light = "latte", dark = "mocha" },
      transparent_background = false,
      integrations = {
        treesitter = true,
        telescope = { enabled = true },
        which_key = true,
        gitsigns = true,
        bufferline = true,
        cmp = true,
        noice = true,
      },
    },
    config = function(_, opts)
      opts.custom_highlights = function(colors)
        return { CodeCell = { bg = colors.surface0 } }
      end
      require("catppuccin").setup(opts)
    end,
  },

  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "night", transparent = false },
    config = function(_, opts)
      require("tokyonight").setup(opts)
    end,
  },

  {
    -- Kanagawa: Japanese woodblock print inspired palette
    "rebelot/kanagawa.nvim",
    lazy = true,
    opts = {
      -- Themes: "wave" (default dark), "dragon" (darker), "lotus" (light)
      theme = "dragon",
      background = { dark = "dragon", light = "lotus" },
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
    end,
  },

  {
    -- Oxocarbon: IBM Carbon design, near-black background
    "nyoom-engineering/oxocarbon.nvim",
    lazy = true,
  },

  {
    -- Gruvbox: retro warm amber/earth tones on near-black
    "ellisonleao/gruvbox.nvim",
    lazy = true,
    -- contrast and background are set per-theme in themery's `before` field
    config = function() end,
  },

  {
    -- Vague: muted, desaturated dark theme with soft contrast
    "vague-theme/vague.nvim",
    lazy = true,
    opts = {},
    config = function(_, opts)
      require("vague").setup(opts)
    end,
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                          THEME MANAGER                                  │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- Themery: persistent theme switcher with a simple UI
    "zaldih/themery.nvim",
    dependencies = {
      "catppuccin/nvim",
      "folke/tokyonight.nvim",
      "rebelot/kanagawa.nvim",
      "nyoom-engineering/oxocarbon.nvim",
      "ellisonleao/gruvbox.nvim",
      "vague-theme/vague.nvim",
    },
    config = function()
      require("themery").setup({
        themes = {
          { name = "Catppuccin Latte",     colorscheme = "catppuccin-latte" },
          { name = "Catppuccin Frappe",    colorscheme = "catppuccin-frappe" },
          { name = "Catppuccin Macchiato", colorscheme = "catppuccin-macchiato" },
          { name = "Catppuccin Mocha",     colorscheme = "catppuccin-mocha" },
          { name = "Tokyo Night Night",    colorscheme = "tokyonight-night" },
          { name = "Tokyo Night Moon",     colorscheme = "tokyonight-moon" },
          { name = "Kanagawa Dragon",      colorscheme = "kanagawa-dragon" },
          { name = "Kanagawa Wave",        colorscheme = "kanagawa-wave" },
          { name = "Oxocarbon",            colorscheme = "oxocarbon" },
          {
            name = "Gruvbox Dark Hard",
            colorscheme = "gruvbox",
            before = [[vim.o.background = "dark"; require("gruvbox").setup({ contrast = "hard" })]],
          },
          {
            name = "Gruvbox Dark Medium",
            colorscheme = "gruvbox",
            before = [[vim.o.background = "dark"; require("gruvbox").setup({ contrast = "medium" })]],
          },
          {
            name = "Gruvbox Dark Soft",
            colorscheme = "gruvbox",
            before = [[vim.o.background = "dark"; require("gruvbox").setup({ contrast = "soft" })]],
          },
          {
            name = "Gruvbox Light Hard",
            colorscheme = "gruvbox",
            before = [[vim.o.background = "light"; require("gruvbox").setup({ contrast = "hard" })]],
          },
          {
            name = "Gruvbox Light Medium",
            colorscheme = "gruvbox",
            before = [[vim.o.background = "light"; require("gruvbox").setup({ contrast = "medium" })]],
          },
          {
            name = "Gruvbox Light Soft",
            colorscheme = "gruvbox",
            before = [[vim.o.background = "light"; require("gruvbox").setup({ contrast = "soft" })]],
          },
          { name = "Vague",                colorscheme = "vague" },
        },
        livePreview = true,
      })

      vim.keymap.set("n", "<leader>ft", "<cmd>Themery<cr>", { desc = "[F]ind [T]heme" })
    end,
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                             STATUSLINE                                  │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "auto", -- Automatically matches the active colorscheme
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { "filename" },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      })
    end,
  },
}
