-- Autocompletion
-- See `:help cmp` or `https://github.com/hrsh7th/nvim-cmp`
return {
    "hrsh7th/nvim-cmp",
    event = "LspAttach",
    dependencies = {
        -- nvim-cmp source for neovim builtin LSP client
        -- nvim-cmp does not ship with all sources by default
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",

        -- Snippet Engine for Neovim written in Lua.
        -- see `https://github.com/L3MON4D3/LuaSnip`
        {
            "L3MON4D3/LuaSnip",
            version = "v2.*",
            -- install jsregexp (optional!).
            build = "make install_jsregexp",
            -- Set of preconfigured snippets for different languages.
            -- see `https://github.com/rafamadriz/friendly-snippets`
            dependencies = { "rafamadriz/friendly-snippets" },
        },
    },
    config = function()
        local cmp = require "cmp"
        local luasnip = require "luasnip"

        luasnip.config.setup {}

        cmp.setup {
            snippet = { -- REQUIRED - you must specify a snippet engine
              expand = function(args)
                luasnip.lsp_expand(args.body) -- For `luasnip` users.
                --vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
              end,
            },
            window = {
              completion = cmp.config.window.bordered(),
              documentation = cmp.config.window.bordered(),
            },
            -- Tip: see `:help ins-completion`
            mapping = cmp.mapping.preset.insert({
              ['<C-b>'] = cmp.mapping.scroll_docs(-4),
              ['<C-f>'] = cmp.mapping.scroll_docs(4),
              ['<C-Space>'] = cmp.mapping.complete(),
              ['<C-e>'] = cmp.mapping.abort(),
              -- ['<C-y>'] = cmp.mapping.confirm { select = true },
              ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            }),
            sources = cmp.config.sources({
              { name = "path" },
              { name = 'nvim_lsp' },
              { name = 'luasnip' }, -- For luasnip users.
              { name = 'buffer' },
            })
        }

        -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline({ '/', '?' }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
              { name = 'buffer' }
            }
          })

          -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
          cmp.setup.cmdline(':', {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
              { name = 'path' }
            }, {
              { name = 'cmdline' }
            }),
            matching = { disallow_symbol_nonprefix_matching = false }
          })


        -- local capabilities = require('cmp_nvim_lsp').default_capabilities()

        -- load frendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()
    end
}
