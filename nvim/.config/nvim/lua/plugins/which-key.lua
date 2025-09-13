--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                             WHICH-KEY                                   │
  │                                                                         │
  │ Which-key shows a popup with available keybindings when you start      │
  │ typing a key sequence. This is incredibly helpful for discovering       │
  │ and remembering keybindings, especially with a leader-key workflow.    │
  │                                                                         │
  │ When you press <space>, after a short delay you'll see all available   │
  │ completions like <space>f for find, <space>g for git, etc.             │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- Which-key plugin for showing keybinding hints
  "folke/which-key.nvim",

  -- Load when Neovim starts (VimEnter event)
  event = "VimEnter",

  -- Configuration
  config = function()
    -- Setup which-key with custom options
    require("which-key").setup({
      -- How long to wait (in milliseconds) before showing the popup
      -- 500ms is a good balance - not too fast to be annoying, not too slow to be helpful
      delay = 100,

      -- Other useful options you can enable:
      preset = "modern",     -- Use modern preset for styling
      -- sort = { "alphanum" }, -- Sort by alphabetical then numerical
      -- expand = 1,           -- Expand group names
    })

    -- Document existing key chains for better organization
    -- This tells which-key about your keybinding groups so it can show meaningful labels
    require("which-key").add({
      -- Buffer operations (matches your VS Code patterns)
      { "<leader>b", group = "[B]uffer" },    -- <space>b shows buffer operations
      { "<leader>bm", group = "[M]ove" },     -- <space>bm shows buffer move operations
      { "<leader>bc", group = "[C]lose" },    -- <space>bc shows buffer close operations

      -- Find operations (telescope integration)
      { "<leader>f", group = "[F]ind" },      -- <space>f shows find operations

      -- Git operations (gitsigns integration)
      { "<leader>g", group = "[G]it" },       -- <space>g shows git operations

      -- Example of how to add more groups as you expand your config:
      -- { "<leader>l", group = "[L]SP" },    -- For future LSP keybindings
      -- { "<leader>d", group = "[D]ebug" },  -- For future debugging keybindings
      -- { "<leader>t", group = "[T]oggle" }, -- For toggling various options
    })
  end,
}
