return {
  {
    "folke/noice.nvim",

    -- Load after startup to not slow down initial load
    event = "VeryLazy",

    dependencies = {
      -- UI component library required by noice
      "MunifTanjim/nui.nvim",
    },

    -- Hide the native cmdline row before noice loads
    init = function()
      vim.opt.cmdheight = 0
    end,

    opts = {
      -- ─────────────────────────────────────────────────────────────────
      --                          CMDLINE
      -- ─────────────────────────────────────────────────────────────────
      -- Replace the bottom cmdline bar with a centered floating popup
      cmdline = {
        enabled = true,
        view = "cmdline_popup",
        format = {
          cmdline  = { icon = ":" },
          search_down = { kind = "search", pattern = "^/",  icon = "/" },
          search_up   = { kind = "search", pattern = "^%?", icon = "?" },
          filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
          lua    = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "" },
          help   = { pattern = "^:%s*he?l?p?%s+", icon = "" },
        },
      },

      -- ─────────────────────────────────────────────────────────────────
      --                          MESSAGES
      -- ─────────────────────────────────────────────────────────────────
      -- Route all messages through the mini view (small inline popups)
      -- instead of the cmdline area
      messages = {
        enabled = true,
        view         = "mini",       -- normal messages
        view_error   = "mini",       -- errors
        view_warn    = "mini",       -- warnings
        view_history = "messages",   -- :messages command output
        view_search  = "virtualtext", -- search count (n/N feedback)
      },

      -- ─────────────────────────────────────────────────────────────────
      --                       COMPLETION POPUPMENU
      -- ─────────────────────────────────────────────────────────────────
      -- Use nui to render the wildmenu inside the cmdline popup
      popupmenu = {
        enabled = true,
        backend = "nui",
      },

      -- ─────────────────────────────────────────────────────────────────
      --                         NOTIFY
      -- ─────────────────────────────────────────────────────────────────
      -- Use mini view for notifications (no nvim-notify required)
      notify = {
        enabled = true,
        view = "mini",
      },

      -- ─────────────────────────────────────────────────────────────────
      --                           LSP
      -- ─────────────────────────────────────────────────────────────────
      lsp = {
        progress = {
          enabled = true,
          view = "mini",
        },
        -- Override vim.lsp rendering functions with nicer Noice versions
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
        hover = { enabled = true, silent = true },
        signature = { enabled = true },
      },

      -- ─────────────────────────────────────────────────────────────────
      --                           PRESETS
      -- ─────────────────────────────────────────────────────────────────
      presets = {
        -- Position cmdline popup and completion menu together
        command_palette = true,
        -- Send long messages to a split instead of a tiny popup
        long_message_to_split = true,
        -- Add border to LSP hover/signature windows
        lsp_doc_border = true,
      },

      -- ─────────────────────────────────────────────────────────────────
      --                           ROUTES
      -- ─────────────────────────────────────────────────────────────────
      -- Suppress noisy low-value messages
      routes = {
        -- Skip the "N lines written" confirmation after :w
        {
          filter = { event = "msg_show", kind = "", find = "written" },
          opts = { skip = true },
        },
        -- Skip search_count (n/N match counter) - shown as virtualtext instead
        {
          filter = { event = "msg_show", kind = "search_count" },
          opts = { skip = true },
        },
      },
    },
  },
}
