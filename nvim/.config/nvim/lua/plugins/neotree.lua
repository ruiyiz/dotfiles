-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  "nvim-neo-tree/neo-tree.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>fe", "<cmd>Neotree toggle reveal<cr>", desc = "Toggle NeoTree" },
  },
  opts = {
    window = {
      position = "current",
    },
    filesystem = {
      follow_current_file = { enabled = true },
      filtered_items = {
        visible = true,
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = {
          ".git",
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
