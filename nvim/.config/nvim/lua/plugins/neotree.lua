-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  event = "VimEnter",
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        -- Don't open if launched with a file argument (let the file take focus)
        if vim.fn.argc() == 0 then
          vim.cmd("Neotree focus")
        end
      end,
    })
  end,
  keys = {
    { "<leader>fe", ":Neotree focus reveal<CR>", desc = "NeoTree" },
  },
  opts = {
    window = {
      position = "left",
    },
    filesystem = {
      follow_current_file = { enabled = true },
      filtered_items = {
        visible = true, -- Show hidden files and directories
        hide_dotfiles = false, -- Don't hide dotfiles
        hide_gitignored = false, -- Don't hide gitignored files
        hide_by_name = {
          ".git", -- Still hide .git directory
        },
      },
      window = {
        mappings = {
          ["<space>"] = "none",
        },
      },
    },
  },
}