--[[
  ╭─────────────────────────────────────────────────────────────────────────╮
  │                             TELESCOPE                                   │
  │                                                                         │
  │ Telescope is a fuzzy finder that replaces the need for file trees      │
  │ for most navigation. It's incredibly fast and can search files,        │
  │ content, buffers, git files, and much more.                            │
  │                                                                         │
  │ Perfect for your workflow since you don't want heavy file navigation.  │
  │ Just press <space>ff to find any file instantly!                       │
  ╰─────────────────────────────────────────────────────────────────────────╯
--]]

return {
  -- Main telescope plugin
  "nvim-telescope/telescope.nvim",

  -- Use the stable 0.1.x branch
  branch = "0.1.x",

  -- Dependencies that telescope needs to function
  dependencies = {
    -- Plenary provides utility functions that many plugins use
    "nvim-lua/plenary.nvim",

    -- FZF native provides faster fuzzy finding (optional but recommended)
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      -- Build the native extension for better performance
      build = "make",
      -- Only install if make is available on the system
      cond = function()
        return vim.fn.executable("make") == 1
      end,
    },
  },

  -- Configuration
  config = function()
    -- Setup telescope with custom options
    require("telescope").setup({
      defaults = {
        -- Show hidden files but exclude certain patterns
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--smart-case",
          "--hidden", -- Search hidden files
          "--glob=!.git/", -- Exclude .git directory
        },

        -- Keybindings inside telescope picker
        mappings = {
          i = { -- Insert mode mappings
            -- Disable default Ctrl+u and Ctrl+d mappings to avoid conflicts
            -- These normally clear the prompt and scroll preview
            ["<C-u>"] = false,
            ["<C-d>"] = false,
          },
        },

        -- Ignore these patterns when searching
        file_ignore_patterns = { "^.git/" },
      },

      -- Specific configuration for find_files picker
      pickers = {
        find_files = {
          hidden = true, -- Show hidden files
          -- Additional ripgrep arguments for find_files
          find_command = { "rg", "--files", "--hidden", "--glob", "!.git/" },
        },
      },
    })

    -- Load the FZF extension if it was built successfully
    -- pcall safely calls the function and won't error if it fails
    pcall(require("telescope").load_extension, "fzf")

    -- ╭─────────────────────────────────────────────────────────────────────╮
    -- │                            KEYMAPS                                  │
    -- ╰─────────────────────────────────────────────────────────────────────╯
    -- Get telescope's built-in functions
    local builtin = require("telescope.builtin")

    -- File operations (matches your VS Code patterns)
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "[F]ind [F]iles" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "[F]ind by [G]rep" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "[F]ind existing [B]uffers" })
    vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "[F]ind [R]ecent files" })
    vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })

    -- Quick buffer access (matches your VS Code "<space>," pattern)
    vim.keymap.set("n", "<leader>,", builtin.buffers, { desc = "Find existing buffers" })

    -- Additional useful telescope functions you can add:
    -- vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
    -- vim.keymap.set("n", "<leader>f/", builtin.current_buffer_fuzzy_find, { desc = "[F]ind in current buffer" })
  end,
}