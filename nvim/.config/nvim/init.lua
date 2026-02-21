require("config.lazy")

-- Open Neo-tree when launching nvim without a file
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 then
      vim.schedule(function()
        vim.cmd("Neotree focus")
      end)
    end
  end,
})
