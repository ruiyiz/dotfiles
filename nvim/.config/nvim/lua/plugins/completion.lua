--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                         COMPLETION PLUGINS                              │
  │                                                                         │
  │ This file configures AI-powered autocompletion with GitHub Copilot     │
  │ integrated into the nvim-cmp completion framework.                      │
  │                                                                         │
  │ Components:                                                             │
  │ - copilot.lua: Lua implementation of GitHub Copilot                    │
  │ - nvim-cmp: Completion engine that shows suggestions in a popup        │
  │ - copilot-cmp: Bridge between Copilot and nvim-cmp                     │
  │ - cmp-buffer: Suggests words from the current buffer                   │
  │ - cmp-path: Suggests file paths                                        │
  │ - LuaSnip: Snippet engine for expandable completions                   │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                          GITHUB COPILOT                                 │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- Lua implementation of GitHub Copilot
    "zbirenbaum/copilot.lua",

    -- Load when entering insert mode (lazy load for faster startup)
    event = "InsertEnter",

    -- Configuration
    opts = {
      -- Panel settings (for viewing multiple suggestions)
      panel = {
        enabled = false, -- Disable panel since we use nvim-cmp
      },

      -- Suggestion settings (inline ghost text)
      suggestion = {
        enabled = false, -- Disable inline suggestions since we use nvim-cmp
      },

      -- Filetypes where Copilot is enabled/disabled
      filetypes = {
        -- Enable for common programming languages
        python = true,
        r = true,
        sql = true,
        lua = true,
        javascript = true,
        typescript = true,
        markdown = true,
        yaml = true,
        json = true,
        -- Disable for sensitive files
        ["."] = false,
        gitcommit = false,
        gitrebase = false,
        [".env"] = false,
      },
    },

    -- After loading, setup copilot-cmp integration
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                       COPILOT-CMP INTEGRATION                           │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- Bridge between copilot.lua and nvim-cmp
    "zbirenbaum/copilot-cmp",

    -- Load after copilot.lua
    dependencies = { "zbirenbaum/copilot.lua" },

    -- Configuration
    opts = {},
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                         SNIPPET ENGINE                                  │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- LuaSnip snippet engine (required for nvim-cmp)
    "L3MON4D3/LuaSnip",

    -- Version constraint for stability
    version = "v2.*",

    -- Build step for optional jsregexp support
    build = "make install_jsregexp",

    -- Lazy load
    lazy = true,
  },

  -- ╭─────────────────────────────────────────────────────────────────────────╮
  -- │                       COMPLETION FRAMEWORK                              │
  -- ╰─────────────────────────────────────────────────────────────────────────╯
  {
    -- nvim-cmp: The completion engine
    "hrsh7th/nvim-cmp",

    -- Load when entering insert mode or using command line
    event = { "InsertEnter", "CmdlineEnter" },

    -- Dependencies for completion sources
    dependencies = {
      "hrsh7th/cmp-buffer",           -- Buffer words
      "hrsh7th/cmp-path",             -- File paths
      "saadparwaiz1/cmp_luasnip",     -- Snippet completions
      "L3MON4D3/LuaSnip",             -- Snippet engine
      "zbirenbaum/copilot-cmp",       -- Copilot suggestions
    },

    -- Configuration
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- ═══════════════════════════════════════════════════════════════════
      --                        HELPER FUNCTIONS
      -- ═══════════════════════════════════════════════════════════════════
      -- Check if there's a word before cursor (for Tab behavior)
      local has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      -- ═══════════════════════════════════════════════════════════════════
      --                           CMP SETUP
      -- ═══════════════════════════════════════════════════════════════════
      cmp.setup({
        -- Snippet expansion (required)
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        -- ─────────────────────────────────────────────────────────────────
        --                          KEY MAPPINGS
        -- ─────────────────────────────────────────────────────────────────
        mapping = cmp.mapping.preset.insert({
          -- Navigate completion menu
          ["<C-n>"] = cmp.mapping.select_next_item(),           -- Next item
          ["<C-p>"] = cmp.mapping.select_prev_item(),           -- Previous item

          -- Scroll documentation window
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),              -- Scroll up
          ["<C-f>"] = cmp.mapping.scroll_docs(4),               -- Scroll down

          -- Confirm completion
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,  -- Only confirm explicitly selected items
          }),

          -- Cancel completion
          ["<C-e>"] = cmp.mapping.abort(),

          -- Tab: Smart completion/snippet navigation
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Shift+Tab: Reverse navigation
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),

        -- ─────────────────────────────────────────────────────────────────
        --                      COMPLETION SOURCES
        -- ─────────────────────────────────────────────────────────────────
        -- Sources are tried in order of priority (higher priority first)
        sources = cmp.config.sources({
          -- Copilot suggestions (highest priority)
          { name = "copilot", group_index = 1, priority = 100 },
          -- Snippet completions
          { name = "luasnip", group_index = 1, priority = 50 },
          -- Buffer words (lower priority, fallback)
          { name = "buffer", group_index = 2, priority = 30 },
          -- File paths
          { name = "path", group_index = 2, priority = 20 },
        }),

        -- ─────────────────────────────────────────────────────────────────
        --                       APPEARANCE
        -- ─────────────────────────────────────────────────────────────────
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },

        -- Formatting: Show source and kind icons
        formatting = {
          format = function(entry, vim_item)
            -- Add source name to the menu
            vim_item.menu = ({
              copilot = "[Copilot]",
              luasnip = "[Snippet]",
              buffer = "[Buffer]",
              path = "[Path]",
            })[entry.source.name]
            return vim_item
          end,
        },

        -- Experimental features
        experimental = {
          ghost_text = false, -- Disable ghost text (we use the menu)
        },
      })
    end,
  },
}
