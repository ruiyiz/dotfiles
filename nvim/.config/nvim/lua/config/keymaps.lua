--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                              KEYMAPS                                    │
  │                                                                         │
  │ This file defines custom key mappings. These extend or override the     │
  │ default Vim key bindings to match the VS Code workflow patterns.       │
  │                                                                         │
  │ Leader key is <Space> (set in lazy.lua)                                │
  │ Local leader key is <\> (set in lazy.lua)                              │
  │                                                                         │
  │ Key mapping anatomy:                                                    │
  │ vim.keymap.set(mode, key, command, options)                            │
  │   - mode: "n" (normal), "i" (insert), "v" (visual), "x" (visual)      │
  │   - key: the key combination to press                                   │
  │   - command: what to execute                                            │
  │   - options: table with desc, silent, etc.                             │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                           SETUP & UTILITIES                            │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Create a shorter alias for vim.keymap.set to reduce repetition
local keymap = vim.keymap.set

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                          FILE OPERATIONS                               │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Save file (matches your VS Code "<space>w" pattern)
keymap("n", "<leader>w", "<cmd>write<cr>", { desc = "Save file" })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                            SEARCH & UI                                 │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Clear search highlights when pressing Escape in normal mode
-- Useful when you've searched for something and want to remove the highlighting
keymap("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                        IMPROVED MOVEMENT                                │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Better up/down movement for wrapped lines
-- When no count is given (e.g., just pressing j), move by display lines (gj/gk)
-- When a count is given (e.g., 5j), move by actual lines (j/k)
-- This is helpful for long markdown lines or code that wraps
keymap({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
keymap({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                           WINDOW MANAGEMENT                             │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Create new window splits (matches your VS Code patterns)
keymap("n", "<leader>h", "<cmd>split<cr>", { desc = "Split horizontal" })    -- <space>h = horizontal split
keymap("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Split vertical" })     -- <space>v = vertical split

-- Window navigation handled by vim-tmux-navigator (Ctrl-h/j/k/l)

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                          BUFFER MANAGEMENT                              │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Navigate between buffers (open files) using Tab (matches your VS Code config)
keymap("n", "<Tab>", "<cmd>bnext<cr>", { desc = "Next buffer" })       -- Tab = next file
keymap("n", "<S-Tab>", "<cmd>bprevious<cr>", { desc = "Previous buffer" }) -- Shift+Tab = previous file

-- Close current buffer (matches your VS Code "<space>bd" pattern)
keymap("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- Quit Neovim
keymap("n", "<leader>q", "<cmd>confirm qall<cr>", { desc = "Quit Neovim" })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                            VISUAL MODE                                  │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Move selected lines up/down in visual mode (matches your VS Code Shift+K/J)
-- The '>+1 and '<-2 refer to the end and start of the visual selection
-- gv=gv reselects the moved text and re-indents it
keymap("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
keymap("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

-- Better indenting in visual mode
-- These keep the visual selection active after indenting so you can indent multiple times
keymap("v", "<", "<gv", { desc = "Indent left" })
keymap("v", ">", ">gv", { desc = "Indent right" })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                           CLIPBOARD TRICKS                              │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Paste without yanking in visual mode
-- Normally when you paste over selected text, Vim yanks the replaced text
-- This mapping pastes from the "black hole register" (_) which discards the replaced text
keymap("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                          AGENT INTEGRATION                             │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Toggle whether Neovim follows files edited by an external coding agent.
-- When on (default), the agent's PostToolUse hook switches Neovim to the edited file.
-- When off, only open buffers are silently reloaded.
vim.g.agent_follow = 1
keymap("n", "<leader>af", function()
  vim.g.agent_follow = vim.g.agent_follow == 1 and 0 or 1
  vim.notify("Agent follow: " .. (vim.g.agent_follow == 1 and "ON" or "OFF"))
end, { desc = "Toggle agent follow" })