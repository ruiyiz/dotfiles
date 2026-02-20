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
      local ns = vim.api.nvim_create_namespace("quarto_cell_hl")

      local function find_code_cells(buf)
        local ok, parser = pcall(vim.treesitter.get_parser, buf)
        if not ok or not parser then return {} end
        local tree = parser:parse()[1]
        if not tree then return {} end
        local query = vim.treesitter.query.parse(parser:lang(), "(fenced_code_block) @cell")
        local cells = {}
        for _, node in query:iter_captures(tree:root(), buf) do
          local sr, _, er, _ = node:range()
          table.insert(cells, { start_row = sr, end_row = er })
        end
        return cells
      end

      local function goto_next_cell()
        local buf = vim.api.nvim_get_current_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        for _, cell in ipairs(find_code_cells(buf)) do
          if cell.start_row > row then
            vim.api.nvim_win_set_cursor(0, { cell.start_row + 2, 0 })
            return
          end
        end
      end

      local function goto_prev_cell()
        local buf = vim.api.nvim_get_current_buf()
        local row = vim.api.nvim_win_get_cursor(0)[1] - 1
        local cells = find_code_cells(buf)
        for i = #cells, 1, -1 do
          if cells[i].end_row <= row then
            vim.api.nvim_win_set_cursor(0, { cells[i].start_row + 2, 0 })
            return
          end
        end
      end

      local function highlight_cells(buf)
        vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
        for _, cell in ipairs(find_code_cells(buf)) do
          for line = cell.start_row, cell.end_row - 1 do
            vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
              line_hl_group = "CodeCell",
              hl_eol = true,
            })
          end
        end
      end

      vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "TextChangedI" }, {
        pattern = { "*.qmd", "*.md" },
        group = vim.api.nvim_create_augroup("QuartoCellHighlight", { clear = true }),
        callback = function(ev) highlight_cells(ev.buf) end,
      })

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
          map("n", "<localleader>rc", function()
            runner.run_cell()
            goto_next_cell()
          end, "Run cell and advance")
          map("n", "<localleader>rl", runner.run_line,  "Run line")
          map("n", "<localleader>ra", function()
            local y = vim.api.nvim_win_get_cursor(0)[1] - 1
            send_cells_combined({ from = { 0, 0 }, to = { y, 0 } })
          end, "Run cell and above")
          map("n", "<localleader>rA", function()
            send_cells_combined({ from = { 0, 0 }, to = { math.huge, 0 } })
          end, "Run all cells")
          map("v", "<localleader>r",  runner.run_range, "Run visual selection")
          map("n", "]x", goto_next_cell, "Next code cell")
          map("n", "[x", goto_prev_cell, "Previous code cell")
          highlight_cells(buf)
        end,
      })
    end,
  },
}
