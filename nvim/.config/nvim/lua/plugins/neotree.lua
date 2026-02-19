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
  keys = {
    { "<leader>fe", ":Neotree toggle reveal<CR>", desc = "NeoTree" },
  },
  opts = {
    window = {
      position = "float",
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