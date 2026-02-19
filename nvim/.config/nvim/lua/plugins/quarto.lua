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
      -- Collect cell texts in a range and send as a single slime call.
      -- The default run_all/run_above send each cell separately, but rapid
      -- successive tmux paste-buffer calls can arrive before radian
      -- re-enables bracketed paste, causing multi-line code to be sent
      -- line-by-line. Combining into one send avoids the race entirely.
      local function send_cells_combined(range)
        local otterkeeper = require("otter.keeper")
        local concat = require("quarto.tools").concat
        local buf = vim.api.nvim_get_current_buf()
        local lang = otterkeeper.get_current_language_context()

        otterkeeper.sync_raft(buf)
        local raft = otterkeeper.rafts[buf]
        if not raft then
          vim.notify("[Quarto] code runner not initialized for this buffer", vim.log.levels.ERROR)
          return
        end

        local chunks = lang and raft.code_chunks[lang] or {}
        local combined = ""
        for _, chunk in ipairs(chunks) do
          if chunk.range.from[1] <= range.to[1] and range.from[1] <= chunk.range.to[1] then
            combined = combined .. concat(chunk.text)
          end
        end

        if combined == "" then
          print("No code chunks found for the current language")
          return
        end

        vim.fn["slime#send"](combined)
      end

      require("quarto").setup({
        codeRunner = {
          enabled = true,
          default_method = "slime",
        },
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
          map("n", "<localleader>ra", function()
            local y = vim.api.nvim_win_get_cursor(0)[1] - 1
            send_cells_combined({ from = { 0, 0 }, to = { y, 0 } })
          end, "Run cell and above")
          map("n", "<localleader>rA", function()
            send_cells_combined({ from = { 0, 0 }, to = { math.huge, 0 } })
          end, "Run all cells")
          map("v", "<localleader>r",  runner.run_range, "Run visual selection")
        end,
      })
    end,
  },
}
