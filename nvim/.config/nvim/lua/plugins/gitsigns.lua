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
      -- Hunk operations (lowercase = hunk-level)
      map("n", "<leader>gs", gitsigns.stage_hunk, { desc = "Git stage hunk" })
      map("n", "<leader>gr", gitsigns.reset_hunk, { desc = "Git reset hunk" })
      map("n", "<leader>gu", gitsigns.undo_stage_hunk, { desc = "Git undo stage hunk" })
      map("n", "<leader>gp", gitsigns.preview_hunk, { desc = "Git preview hunk" })

      -- Visual mode: stage/reset selected lines within a hunk
      map("v", "<leader>gs", function()
        gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Git stage selected lines" })
      map("v", "<leader>gr", function()
        gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, { desc = "Git reset selected lines" })

      -- Buffer operations (uppercase = whole file)
      map("n", "<leader>gS", gitsigns.stage_buffer, { desc = "Git stage buffer" })
      map("n", "<leader>gR", gitsigns.reset_buffer, { desc = "Git reset buffer" })

      -- Info
      map("n", "<leader>gb", function()
        gitsigns.blame_line({ full = true })
      end, { desc = "Git blame line" })
      map("n", "<leader>gd", gitsigns.diffthis, { desc = "Git diff against index" })
      map("n", "<leader>gD", function()
        gitsigns.diffthis("~")
      end, { desc = "Git diff against last commit" })

      -- Toggles
      map("n", "<leader>gB", gitsigns.toggle_current_line_blame, { desc = "Toggle inline blame" })
      map("n", "<leader>gx", gitsigns.toggle_deleted, { desc = "Toggle deleted lines" })

      -- ═══════════════════════════════════════════════════════════════════
      --                          TEXT OBJECTS
      -- ═══════════════════════════════════════════════════════════════════
      -- Create a text object for selecting git hunks
      -- This allows you to do things like "dih" (delete in hunk) or "yih" (yank in hunk)
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "Select git hunk" })
    end,
  },
}