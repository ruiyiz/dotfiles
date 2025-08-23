return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = { 'org' },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = { 'org' },
      },
    },
    config = function(_, opts)
      require('nvim-treesitter.configs').setup(opts)

      -- Register org parser
      local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
      parser_config.org = {
        install_info = {
          url = 'https://github.com/milisims/tree-sitter-org',
          files = { 'src/parser.c', 'src/scanner.c' },
          branch = 'main',
        },
        filetype = 'org',
      }
    end,
  },
}
