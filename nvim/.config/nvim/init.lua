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

-- Clean up the [No Name] buffer when the first real file is opened
vim.api.nvim_create_autocmd("BufReadPost", {
  once = true,
  callback = function()
    vim.schedule(function()
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if
          vim.api.nvim_buf_is_valid(buf)
          and vim.api.nvim_buf_get_name(buf) == ""
          and vim.bo[buf].buftype == ""
          and vim.api.nvim_buf_line_count(buf) <= 1
          and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == ""
          and not vim.bo[buf].modified
        then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    end)
  end,
})
