--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                             GITSIGNS                                    │
  │                                                                         │
  │ Gitsigns shows git information in the sign column (left side of        │
  │ editor) and provides commands for git operations like staging hunks,   │
  │ viewing diffs, and navigating changes.                                  │
  │                                                                         │
  │ Perfect for quick git operations without leaving Neovim.               │
  │ Essential for data science workflows with version control.             │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- Gitsigns plugin for git integration
  "lewis6991/gitsigns.nvim",

  -- Configuration using opts (shorthand for config function)
  opts = {
    -- ╭─────────────────────────────────────────────────────────────────────╮
    -- │                           SIGN SYMBOLS                             │
    -- ╰─────────────────────────────────────────────────────────────────────╯
    -- Define what symbols appear in the sign column for different git states
    signs = {
      add = { text = "+" },          -- New lines added
      change = { text = "~" },       -- Lines modified
      delete = { text = "_" },       -- Lines deleted
      topdelete = { text = "‾" },    -- Lines deleted at top of file
      changedelete = { text = "~" }, -- Lines changed and deleted
    },

    -- ╭─────────────────────────────────────────────────────────────────────╮
    -- │                            KEYMAPS                                  │
    -- ╰─────────────────────────────────────────────────────────────────────╯
    -- This function runs for each buffer that has git tracking
    on_attach = function(bufnr)
      local gitsigns = require("gitsigns")

      -- Helper function to create buffer-specific keymaps
      local function map(mode, l, r, opts)
        opts = opts or {}
        opts.buffer = bufnr -- Make keymap only work in this specific buffer
        vim.keymap.set(mode, l, r, opts)
      end

      -- ═══════════════════════════════════════════════════════════════════
      --                           NAVIGATION
      -- ═══════════════════════════════════════════════════════════════════
      -- Jump to next git change (hunk)
      map("n", "]c", function()
        if vim.wo.diff then
          -- If we're in diff mode, use Vim's built-in ]c
          vim.cmd.normal({ "]c", bang = true })
        else
          -- Otherwise use gitsigns navigation
          gitsigns.next_hunk()
        end
      end, { desc = "Jump to next git change" })

      -- Jump to previous git change (hunk)
      map("n", "[c", function()
        if vim.wo.diff then
          -- If we're in diff mode, use Vim's built-in [c
          vim.cmd.normal({ "[c", bang = true })
        else
          -- Otherwise use gitsigns navigation
          gitsigns.prev_hunk()
        end
      end, { desc = "Jump to previous git change" })

      -- ═══════════════════════════════════════════════════════════════════
      --                        GIT OPERATIONS
      -- ═══════════════════════════════════════════════════════════════════
      -- Stage the current hunk (add to git staging area)
      map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git stage hunk" })

      -- Reset the current hunk (discard changes)
      map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git reset hunk" })

      -- Preview the current hunk in a floating window
      map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git preview hunk" })

      -- Show git blame for the current line (who changed it and when)
      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true }) -- full=true shows complete commit info
      end, { desc = "Git blame line" })

      -- Show diff of current file against the git index (staged changes)
      map("n", "<leader>gd", gitsigns.diffthis, { desc = "Git diff against index" })

      -- Show diff of current file against the last commit
      map("n", "<leader>gD", function()
        gitsigns.diffthis("~") -- ~ refers to the previous commit
      end, { desc = "Git diff against last commit" })

      -- ═══════════════════════════════════════════════════════════════════
      --                          TEXT OBJECTS
      -- ═══════════════════════════════════════════════════════════════════
      -- Create a text object for selecting git hunks
      -- This allows you to do things like "dih" (delete in hunk) or "yih" (yank in hunk)
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
    end,
  },
}