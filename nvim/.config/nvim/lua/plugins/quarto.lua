return {
  -- vim-slime: sends text to a tmux pane
  -- Only loads when inside a tmux session ($TMUX is set)
  {
    "jpalardy/vim-slime",
    cond = function()
      return vim.env.TMUX ~= nil
    end,
    ft = { "quarto", "markdown", "python", "r" },
    init = function()
      vim.g.slime_target = "tmux"
      -- Prefer the stable pane ID set by tdev (TDEV_REPL_PANE="%2" etc.)
      -- Falls back to {last} when launched outside of tdev
      vim.g.slime_default_config = {
        socket_name = "default",
        target_pane = vim.env.TDEV_REPL_PANE or "{last}",
      }
      vim.g.slime_dont_ask_default = 1
      -- Required for multi-line code blocks (R, Python indentation)
      vim.g.slime_bracketed_paste = 1
    end,
  },

  -- otter.nvim: embedded language support inside code cells (completion, diagnostics, hover)
  {
    "jmbuhr/otter.nvim",
    lazy = true,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },

  -- quarto-nvim: Tree-sitter cell detection + runner orchestration + LSP via otter
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto", "markdown" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("quarto").setup({
        codeRunner = {
          enabled = true,
          default_method = "slime",
        },
        -- LSP features via otter.nvim: completion and diagnostics inside code cells
        -- Requires language servers to be installed:
        --   R:      install.packages("languageserver")  in R
        --   Python: pyright or similar already on $PATH
        lspFeatures = {
          enabled = true,
          languages = { "r", "python" },
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
      })

      -- Register buffer-local keymaps only for quarto/markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "quarto", "markdown" },
        group = vim.api.nvim_create_augroup("QuartoKeymaps", { clear = true }),
        callback = function(event)
          local runner = require("quarto.runner")
          local buf = event.buf
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, silent = true })
          end
          map("n", "<localleader>rc", runner.run_cell,  "Run cell")
          map("n", "<localleader>rl", runner.run_line,  "Run line")
          map("n", "<localleader>ra", runner.run_above, "Run cell and above")
          map("n", "<localleader>rA", runner.run_all,   "Run all cells")
          map("v", "<localleader>r",  runner.run_range, "Run visual selection")
        end,
      })
    end,
  },
}
