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

      -- Send a list of cells as a single slime call to avoid bracketed-paste
      -- race conditions when sending multiple chunks rapidly to radian.
      local function send_cells_list(buf, cells_list)
        local all_lines = {}
        for _, cell in ipairs(cells_list) do
          local first_line = vim.api.nvim_buf_get_lines(buf, cell.start_row, cell.start_row + 1, false)[1] or ""
          if first_line:match("^```%s*{r") then
            local code_lines = vim.api.nvim_buf_get_lines(buf, cell.start_row + 1, cell.end_row - 1, false)
            for _, line in ipairs(code_lines) do
              if not line:match("^#|") then
                table.insert(all_lines, line)
              end
            end
            table.insert(all_lines, "")
          end
        end
        if #all_lines == 0 then
          print("No R code chunks found")
          return
        end
        vim.fn["slime#send"](table.concat(all_lines, "\n"))
      end

      -- Returns the index of the cell containing `row`, or nil if between cells.
      local function find_current_cell_index(cells, row)
        for i, cell in ipairs(cells) do
          if cell.start_row <= row and row <= cell.end_row then
            return i
          end
        end
        return nil
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
          map("n", "<localleader>rl", runner.run_line, "Run line")
          map("n", "<localleader>rR", function()
            send_cells_list(buf, find_code_cells(buf))
          end, "Run all cells")
          map("n", "<localleader>rA", function()
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            local cells = find_code_cells(buf)
            local idx = find_current_cell_index(cells, row)
            local limit = idx and (idx - 1) or #cells
            local above = {}
            for i = 1, limit do above[#above + 1] = cells[i] end
            send_cells_list(buf, above)
          end, "Run all above (exclusive)")
          map("n", "<localleader>rB", function()
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            local cells = find_code_cells(buf)
            local idx = find_current_cell_index(cells, row)
            local below = {}
            for i = (idx and idx + 1 or 1), #cells do below[#below + 1] = cells[i] end
            send_cells_list(buf, below)
          end, "Run all below (exclusive)")
          map("n", "<localleader>ra", function()
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            local cells = find_code_cells(buf)
            local idx = find_current_cell_index(cells, row)
            local prev
            if idx and idx > 1 then
              prev = idx - 1
            elseif not idx then
              for i = #cells, 1, -1 do
                if cells[i].end_row < row then prev = i; break end
              end
            end
            if prev then send_cells_list(buf, { cells[prev] }) else print("No previous cell") end
          end, "Run prev cell")
          map("n", "<localleader>rb", function()
            local row = vim.api.nvim_win_get_cursor(0)[1] - 1
            local cells = find_code_cells(buf)
            local idx = find_current_cell_index(cells, row)
            local nxt
            if idx and idx < #cells then
              nxt = idx + 1
            elseif not idx then
              for i = 1, #cells do
                if cells[i].start_row > row then nxt = i; break end
              end
            end
            if nxt then send_cells_list(buf, { cells[nxt] }) else print("No next cell") end
          end, "Run next cell")
          -- <Plug>SlimeRegionSend uses `:call` which exits visual mode first,
          -- ensuring '< and '> marks are updated before slime#send_range runs.
          -- remap=true is required for <Plug> expansion (map helper uses noremap).
          vim.keymap.set("v", "<localleader>r", "<Plug>SlimeRegionSend",
            { buffer = buf, desc = "Run visual selection", silent = true, remap = true })
          map("n", "]x", goto_next_cell, "Next code cell")
          map("n", "[x", goto_prev_cell, "Previous code cell")
          highlight_cells(buf)
        end,
      })
    end,
  },
}
