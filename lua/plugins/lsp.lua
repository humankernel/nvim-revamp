-- see :help lspconfig or :help lsp or `https://github.com/neovim/nvim-lspconfig`
return {
    {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        -- Portable package manager for Neovim that runs everywhere Neovim runs.
        -- Easily install and manage LSP servers, DAP servers, linters, and formatters.
        "williamboman/mason.nvim",
        -- Extension to mason.nvim that makes it easier to use lspconfig with mason.nvim.
        "williamboman/mason-lspconfig.nvim",
        -- Install and upgrade third party tools automatically
        "WhoIsSethDaniel/mason-tool-installer.nvim",

        -- nvim-cmp source for neovim builtin LSP client
        "hrsh7th/cmp-nvim-lsp"
    },
    config = function ()
        --  this run when an LSP attaches to a particular buffer.
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup( "lsp-attach", { clear = true }),
            callback = function(event)
                -- go to definition of the word under your cursor.
                vim.keymap.set("n", "gd",
                    require("telescope.builtin").lsp_definitions,
                    { buffer = event.buf, desc = "LSP: [G]oto [D]efinition" }
                )

                -- go to references for the word under your cursor.
                vim.keymap.set("n", "gr",
                    require("telescope.builtin").lsp_references,
                    { buffer = event.buf, desc = "LSP: [G]oto [R]eferences" }
                )

                -- go to implementation of the word under your cursor.
                -- Tip: Useful when your language has ways of declaring types without an actual implementation.
                vim.keymap.set("n", "gI",
                    require("telescope.builtin").lsp_implementations,
                    { buffer = event.buf, desc = "LSP: [G]oto [I]mplementation" }
                )

                -- the type definition of the word under your cursor.
                -- Tip: Useful when you're not sure what type a variable is and you want to see
                vim.keymap.set("n", "<leader>D",
                    require("telescope.builtin").lsp_type_definitions,
                    { buffer = event.buf, desc = "LSP: Type [D]efinition" }
                )

                -- fuzzy find all the symbols in your current document.
                -- Tip: Symbols are things like variables, functions, types, etc.
                vim.keymap.set("n", "<leader>fs",
                    require("telescope.builtin").lsp_document_symbols,
                    { buffer = event.buf, desc = "LSP: [D]ocument [S]ymbols" }
                )

                -- fuzzy find all the symbols in your current workspace.
                -- Tip: Similar to document symbols, except searches over your entire project.
                vim.keymap.set("n", "<leader>fws",
                    require("telescope.builtin").lsp_dynamic_workspace_symbols,
                    { buffer = event.buf, desc = "LSP: [W]orkspace [S]ymbols" }
                )

                -- rename the variable under your cursor.
                -- Tip: Most Language Servers support renaming across files, etc.
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, { desc = "LSP: [R]e[n]ame"})

                -- code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP: [C]ode [A]ction"})

                -- popup documentation about the word under your cursor
                --  See `:help K` for why this keymap.
                vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "LSP: Hover Documentation" })

                -- go to declaration.
                -- Tip: For example, in C this would take you to the header.
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { desc = "LSP [G]oto [D]eclaration" })

                -- Tip: The following two autocommands are used to highlight references of the
                -- word under your cursor when your cursor rests there for a little while.
                -- See `:help CursorHold` for information about when this is executed
                -- When you move your cursor, the highlights will be cleared (the second autocommand).
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    vim.api.nvim_create_autocmd(
                        { "CursorHold", "CursorHoldI" },
                        {
                            buffer = event.buf,
                            callback = vim.lsp.buf.document_highlight,
                        }
                    )

                    vim.api.nvim_create_autocmd(
                        { "CursorMoved", "CursorMovedI" },
                        {
                            buffer = event.buf,
                            callback = vim.lsp.buf.clear_references,
                        }
                    )
                end
            end,
        })

        -- Tip: LSP servers and clients are able to communicate to each other what features they support.
        -- By default, Neovim doesn't support everything that is in the LSP specification.
        -- When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
        -- So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
        local capabilities = vim.lsp.protocol.make_client_capabilities()
        capabilities = vim.tbl_deep_extend(
            "force",
            capabilities,
            require("cmp_nvim_lsp").default_capabilities()
        )

        -- Tip: Available keys are:
        -- - cmd (table): Override the default command used to start the server
        -- - filetypes (table): Override the default list of associated filetypes for the server
        -- - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
        -- - settings (table): Override the default settings passed when initializing the server.
        -- For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        -- see `:help lspconfig-all` for a list of all the pre-configured LSPs
        local servers = {
            lua_ls = {
                settings = {
                    Lua = {
                        completion = { callSnippet = "Replace", },
                        diagnostics = { disable = { 'missing-fields' } },
                    },
                },
            },
            pyright = {},
            clangd = {},
            marksman = {},
        }

        -- Tip: Ensure the servers and tools above are installed
        require("mason").setup {
            max_concurrent_installers = 1,
            registries = { "github:mason-org/mason-registry" },
            ui = {
                border = "rounded",
                icons = {
                    package_installed = '',
                    package_pending = '',
                    package_uninstalled = '',
                }
            },
            -- pip = { Example: { "--proxy", "https://proxyserver" } },
        }

        require("mason-lspconfig").setup {
            ensure_installed = vim.tbl_keys(servers or {}),
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    server.capabilities = vim.tbl_deep_extend(
                        "force", -- override only values that confict
                        {},
                        capabilities,
                        server.capabilities or {}
                    )
                    require("lspconfig")[server_name].setup(server)
                end,
            },
        }

        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            "luacheck", -- lua linter
            "stylua", -- lua formatter
            "ruff", -- python formatter & linter
            "clang_format", -- c/cpp formatter
            "prettierd", -- js/ts formatter
        })
        require("mason-tool-installer").setup {
            ensure_installed = ensure_installed,
            run_on_start = false,
        }

        -- Tip: you can customize icons
        local signs = { Error = '', Warn = '', Hint = '󰠠', Info = '', }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end
    end
    },
    -- TypeScript integration NeoVim deserves
    -- see `https://github.com/pmizio/typescript-tools.nvim`
    {
        "pmizio/typescript-tools.nvim",
        enable = false,
        event = { "BufReadPre" },
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        opts = {
            settings = {
                -- WARNING: it is disabled by default (maybe you configuration or distro already uses nvim-ts-autotag,
                -- that maybe have a conflict if enable this feature. )
                jsx_close_tag = {
                    enable = true,
                    filetypes = { "javascriptreact", "typescriptreact" },
                }
            }
        },
    },
    -- Clangd's off-spec features for neovim's LSP client
    -- see `https://github.com/p00f/clangd_extensions.nvim`
    { "p00f/clangd_extensions.nvim", event = "BufReadPre"  }
}
