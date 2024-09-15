-- Treesitter configurations and abstraction layer for Neovim.
-- see `:help nvim-treesitter` or `https://github.com/nvim-treesitter/nvim-treesitter`
return {
    "nvim-treesitter/nvim-treesitter",
    lazy = true,
    event = "VeryLazy",
    build = ":TSUpdate",
    opts = {
        -- Automatically install missing parsers when entering buffer
        -- Tip: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,
      ensure_installed = {
          "c", "cpp", "lua", "vim", "vimdoc", "javascript", "typescript", "python" },
      sync_install = false,
      indent = { enable = true },
      highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
      },

    },
    config = function (_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end
}
