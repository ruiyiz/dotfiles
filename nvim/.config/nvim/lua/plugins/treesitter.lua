--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                            TREESITTER                                   │
  │                                                                         │
  │ Treesitter provides syntax highlighting, indentation, and text objects │
  │ based on language parsers. It's much more accurate than regex-based    │
  │ syntax highlighting.                                                    │
  │                                                                         │
  │ This is essential for data science languages like Python, R, SQL.      │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- Main treesitter plugin
  "nvim-treesitter/nvim-treesitter",

  -- Build step: run :TSUpdate after installation to compile parsers
  build = ":TSUpdate",

  -- Configuration function runs after the plugin is loaded
  config = function()
    require("nvim-treesitter.configs").setup({
      -- Languages to automatically install parsers for
      -- These cover your data science and documentation needs
      ensure_installed = {
        "lua",            -- Neovim configuration
        "vim",            -- Vim script
        "python",         -- Data science
        "r",              -- Statistics and data analysis
        "sql",            -- Database queries
        "markdown",       -- Documentation (including Obsidian)
        "markdown_inline", -- Inline markdown elements
        "json",           -- Configuration files
        "yaml",           -- Configuration files
        "bash",           -- Shell scripts
      },

      -- Automatically install parsers for languages when you open files
      -- Convenient for when you encounter new file types
      auto_install = true,

      -- Enable syntax highlighting
      highlight = {
        enable = true,
        -- Optional: disable for large files to improve performance
        -- disable = function(lang, buf)
        --   local max_filesize = 100 * 1024 -- 100 KB
        --   local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        --   if ok and stats and stats.size > max_filesize then
        --     return true
        --   end
        -- end,
      },

      -- Enable treesitter-based indentation
      -- This provides better auto-indenting for supported languages
      indent = {
        enable = true,
      },
    })
  end,
}