--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                              VIM OPTIONS                                │
  │                                                                         │
  │ This file configures Neovim's built-in options. These are equivalent   │
  │ to the :set commands you might run in Vim, but configured in Lua.      │
  │                                                                         │
  │ vim.opt is the modern Lua way to set options (replaces vim.o/vim.wo)   │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                             LINE NUMBERS                                │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.opt.number = true         -- Show absolute line numbers in the left gutter
vim.opt.relativenumber = true -- Show relative line numbers (current line shows absolute)
                             -- This combo helps with motion commands like "5j" to go down 5 lines

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                             INDENTATION                                 │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.opt.tabstop = 2      -- Number of spaces a <Tab> character represents when displayed
vim.opt.shiftwidth = 2   -- Number of spaces used for each indentation level (>>, <<, auto-indent)
vim.opt.expandtab = true -- Convert tabs to spaces when typing <Tab>
vim.opt.autoindent = true -- Copy indent from current line when starting a new line
                         -- Good for Python, R, and general data science code

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                               SEARCH                                    │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.opt.ignorecase = true -- Ignore case when searching (e.g., "hello" matches "Hello")
vim.opt.smartcase = true  -- Override ignorecase if search contains uppercase letters
                         -- Together: "hello" matches "Hello", but "Hello" only matches "Hello"
vim.opt.hlsearch = false  -- Don't highlight all search matches (can be distracting)
vim.opt.incsearch = true  -- Show search matches as you type (incremental search)

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                              APPEARANCE                                 │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.opt.termguicolors = true -- Enable 24-bit RGB colors in the terminal
vim.opt.signcolumn = "yes"   -- Always show the sign column (where git signs, diagnostics appear)
                            -- Prevents text from shifting when signs appear/disappear
vim.opt.wrap = false         -- Don't wrap long lines (horizontal scrolling instead)
vim.opt.cursorline = true    -- Highlight the current line where the cursor is
vim.opt.scrolloff = 8        -- Keep 8 lines above/below cursor when scrolling
vim.opt.sidescrolloff = 8    -- Keep 8 columns left/right of cursor when scrolling horizontally

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                              BEHAVIOR                                   │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.opt.hidden = true        -- Allow switching buffers without saving current buffer first
vim.opt.errorbells = false   -- Don't make noise on errors

-- File handling - disable swap and backup files, enable persistent undo
vim.opt.swapfile = false                                -- Don't create .swp files
vim.opt.backup = false                                  -- Don't create backup files
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")      -- Directory for undo files
vim.opt.undofile = true                                 -- Save undo history to file (persistent undo)

-- Editing behavior
vim.opt.backspace = "indent,eol,start"  -- Allow backspace over indentation, line breaks, and start of insert
vim.opt.splitright = true               -- New vertical splits open to the right
vim.opt.splitbelow = true               -- New horizontal splits open below
vim.opt.iskeyword:append("-")           -- Treat hyphenated words as single words (useful for CSS, markdown)

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                              CLIPBOARD                                  │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Connect Neovim's clipboard to system clipboard
-- This means y/p commands work with Cmd+C/Cmd+V on macOS
vim.opt.clipboard:append("unnamedplus")

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                                MOUSE                                    │
-- ╰─────────────────────────────────────────────────────────────────────────╯
-- Enable mouse support in all modes (normal, visual, insert, command)
-- Useful for clicking to position cursor, scrolling, selecting text
vim.opt.mouse = "a"

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                            SOFT WRAP                                    │
-- │                                                                         │
-- │ Enable soft wrap for prose-oriented filetypes (markdown, text, quarto) │
-- │ while keeping wrap off for code files (the default set above).         │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text", "quarto", "rst", "tex", "latex", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true       -- Enable soft wrap
    vim.opt_local.linebreak = true  -- Wrap at word boundaries, not mid-word
    vim.opt_local.breakindent = true -- Preserve indentation on wrapped lines
  end,
})

-- ╭─────────────────────────────────────────────────────────────────────────╮
-- │                          EXTERNAL CHANGES                              │
-- │                                                                         │
-- │ Auto-reload files modified outside Neovim (e.g., by a coding agent    │
-- │ running in another tmux pane).                                         │
-- ╰─────────────────────────────────────────────────────────────────────────╯
vim.opt.autoread = true

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk. Reloaded.", vim.log.levels.INFO)
  end,
})