--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                            BUFFERLINE                                   │
  │                                                                         │
  │ Bufferline provides a tab-like interface at the top of Neovim,         │
  │ similar to VS Code, Sublime Text, and other modern editors.            │
  │                                                                         │
  │ It shows your open buffers (files) as clickable tabs with:             │
  │ - File names and icons                                                  │
  │ - Modified indicators                                                   │
  │ - Close buttons                                                         │
  │ - Git status integration                                                │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- Bufferline plugin for IDE-like tabs
  "akinsho/bufferline.nvim",

  -- Requires devicons for file type icons
  dependencies = { "nvim-tree/nvim-web-devicons" },

  -- Version constraint for stability
  version = "*",

  -- Configuration
  config = function()
    require("bufferline").setup({
      options = {
        -- ═══════════════════════════════════════════════════════════════════
        --                           APPEARANCE
        -- ═══════════════════════════════════════════════════════════════════
        -- Style of the tabs ("slant", "slope", "thick", "thin")
        separator_style = "thin",

        -- Show buffer numbers for easy navigation (1, 2, 3, etc.)
        -- numbers = "ordinal",

        -- Show close button on tabs
        show_close_icon = true,
        show_buffer_close_icons = true,

        -- Show file type icons
        show_buffer_icons = true,

        -- Show modified indicator (dot when file has unsaved changes)
        modified_icon = "●",

        -- Maximum length of buffer names before truncating
        max_name_length = 30,
        max_prefix_length = 15,
        truncate_names = false,

        -- Strip extension and middle-truncate long names
        name_formatter = function(buf)
          local name = buf.name:match("(.+)%..+$") or buf.name
          local max_len = 18
          if #name <= max_len then
            return name
          end
          local side = math.floor((max_len - 1) / 2)
          return name:sub(1, side) .. "…" .. name:sub(-side)
        end,

        -- ═══════════════════════════════════════════════════════════════════
        --                            BEHAVIOR
        -- ═══════════════════════════════════════════════════════════════════
        -- Enforce regular tabs (don't group by directory)
        enforce_regular_tabs = false,

        -- Always show bufferline even with single buffer
        always_show_bufferline = true,

        -- Sort buffers by extension, then by relative directory
        sort_by = "insert_after_current",

        -- ═══════════════════════════════════════════════════════════════════
        --                         MOUSE SUPPORT
        -- ═══════════════════════════════════════════════════════════════════
        -- Left click to go to buffer, middle click to delete
        left_mouse_command = "buffer %d",       -- Left click switches to buffer
        middle_mouse_command = "bdelete! %d",   -- Middle click closes buffer
        right_mouse_command = "bdelete! %d",    -- Right click closes buffer

        -- ═══════════════════════════════════════════════════════════════════
        --                           INTEGRATION
        -- ═══════════════════════════════════════════════════════════════════
        -- Don't show bufferline when certain filetypes are focused
        offsets = {
          {
            filetype = "NvimTree",    -- Hide when file tree is open
            text = "File Explorer",
            text_align = "left",
            separator = true,
          },
        },

        -- Color integration with your colorscheme
        themable = true,

        -- ═══════════════════════════════════════════════════════════════════
        --                            HIGHLIGHTS
        -- ═══════════════════════════════════════════════════════════════════
        -- Custom highlight groups (automatically syncs with catppuccin)
        -- You can customize these if you want different colors:
        -- highlights = {
        --   buffer_selected = {
        --     bold = true,
        --     italic = false,
        --   },
        -- },
      },
    })

    -- ╭─────────────────────────────────────────────────────────────────────╮
    -- │                           KEYMAPS                                   │
    -- ╰─────────────────────────────────────────────────────────────────────╯
    -- Enhanced buffer navigation keymaps that work with bufferline

    -- Go to specific buffer by number (Alt + number)
    for i = 1, 9 do
      vim.keymap.set("n", "<A-" .. i .. ">", function()
        require("bufferline").go_to_buffer(i, true)
      end, { desc = "Go to buffer " .. i })
    end

    -- Buffer navigation with visual feedback
    vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
    vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Previous buffer" })

    -- Move buffers left/right in the tab bar
    vim.keymap.set("n", "<leader>bmh", "<cmd>BufferLineMovePrev<cr>", { desc = "Move buffer left" })
    vim.keymap.set("n", "<leader>bml", "<cmd>BufferLineMoveNext<cr>", { desc = "Move buffer right" })

    -- Close buffers with bufferline integration
    vim.keymap.set("n", "<leader>bc", "<cmd>BufferLinePickClose<cr>", { desc = "Pick buffer to close" })
    vim.keymap.set("n", "<leader>bco", "<cmd>BufferLineCloseOthers<cr>", { desc = "Close other buffers" })
    vim.keymap.set("n", "<leader>bcr", "<cmd>BufferLineCloseRight<cr>", { desc = "Close buffers to right" })
    vim.keymap.set("n", "<leader>bcl", "<cmd>BufferLineCloseLeft<cr>", { desc = "Close buffers to left" })

    -- Pick buffer (shows letters over tabs for quick selection)
    vim.keymap.set("n", "<leader>bp", "<cmd>BufferLinePick<cr>", { desc = "Pick buffer" })

    -- Toggle pin (keeps important buffers always visible)
    vim.keymap.set("n", "<leader>bP", "<cmd>BufferLineTogglePin<cr>", { desc = "Pin/unpin buffer" })
  end,
}