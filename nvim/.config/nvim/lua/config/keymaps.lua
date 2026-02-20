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

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                         SMART QUIT BEHAVIOR                             │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Prevent accidental quit when habitually typing :q
-- Smart behavior: close buffer if multiple buffers exist, otherwise quit Neovim
-- This mimics modern editors with tabs - :q closes the "tab", not the entire editor
local function has_neotree_sidebar()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    if w ~= vim.api.nvim_get_current_win() then
      local ft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
      if ft == "neo-tree" then
        return true
      end
    end
  end
  return false
end

local function smart_quit()
  -- Get list of buffers that are listed (visible in buffer list)
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })

  -- Count how many real buffers we have (exclude empty unnamed buffers)
  local real_buffers = 0
  for _, buf in ipairs(buffers) do
    -- A real buffer has either a name or has been modified
    if buf.name ~= "" or buf.changed == 1 then
      real_buffers = real_buffers + 1
    end
  end

  if real_buffers > 1 then
    -- Multiple real buffers: just close this one
    vim.cmd("bdelete")
  elseif real_buffers == 1 and has_neotree_sidebar() then
    -- Last real buffer with neo-tree open: close it (neovim auto-creates an empty buffer)
    vim.cmd("bdelete")
  elseif real_buffers == 0 and has_neotree_sidebar() then
    -- Empty buffer with neo-tree: quit everything
    vim.cmd("qall")
  else
    vim.cmd("quit")
  end
end

-- Remap :q command to use smart quit
-- Use command! to override the built-in :q command
vim.api.nvim_create_user_command("Q", smart_quit, { desc = "Smart quit (close buffer or quit Neovim)" })

-- Also create an autocmd to remap the lowercase :q
vim.api.nvim_create_user_command("SmartQ", smart_quit, { desc = "Smart quit (close buffer or quit Neovim)" })

-- Create command abbreviation so :q becomes :SmartQ
-- This works in command mode and triggers when you type :q followed by Enter
vim.cmd([[
  cnoreabbrev <expr> q ((getcmdtype() is# ':' && getcmdline() is# 'q')?('SmartQ'):('q'))
  cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('SmartQ'):('Q'))
]])

-- Note: :q! and :qa still work as normal for force quit and quit all


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