-- Find, Filter, Preview, Pick. All lua, all the time.
-- see `https://github.com/nvim-telescope/telescope.nvim`
return {
    'nvim-telescope/telescope.nvim', branch = '0.1.x',
    lazy = true,
    event = "VeryLazy",
    dependencies = {
        'nvim-lua/plenary.nvim',
        -- native telescope sorter to significantly improve sorting performance
        { 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
        -- A telescope.nvim extension that offers intelligent prioritization when selecting files from your editing history.
        -- see `https://github.com/nvim-telescope/telescope-frecency.nvim`
        "nvim-telescope/telescope-frecency.nvim",

        -- This plugin is also overriding dap internal ui, so running any dap command, which makes use of the internal ui, will result in a telescope prompt.
        -- see `https://github.com/nvim-telescope/telescope-dap.nvim`

        -- icons, requires a Nerd Font
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        pickers = {
            find_files = { theme = "dropdown" },
        },
        extensions = {
            ['ui-select'] = { require('telescope.themes').get_dropdown {}, },
            frecency = {
                default_workspace = 'CWD',
                show_scores = true,
                show_unindexed = true,
                disable_devicons = false,
                ignore_patterns = {
                    '*.git/*',
                    '*/tmp/*',
                    '*/lua-language-server/*',
                },
            },
        },
    },
    config = function ()
        pcall(require('telescope').load_extension, 'fzf')
        pcall(require('telescope').load_extension, 'frecency')
        pcall(require('telescope').load_extension, 'lazy_plugins')

        -- see `:help telescope.builtin`
        local builtin = require('telescope.builtin')
        vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
        vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
        vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
        vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
        vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
        vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
        -- vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
        -- vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
        -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })

        -- example of overriding default behavior and theme
        vim.keymap.set('n', '<leader>/', function()
            -- You can pass additional configuration to Telescope to change the theme, layout, etc.
            builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
            })
        end, { desc = '[/] Fuzzily search in current buffer' })

        -- It's also possible to pass additional configuration options.
        --  See `:help telescope.builtin.live_grep()` for information about particular keys
        vim.keymap.set('n', '<leader>s/', function()
            builtin.live_grep {
                grep_open_files = true,
                prompt_title = 'Live Grep in Open Files',
            }
        end, { desc = '[S]earch [/] in Open Files' })

        -- Shortcut for searching your Neovim configuration files
        vim.keymap.set('n', '<leader>sn', function()
            builtin.find_files { cwd = vim.fn.stdpath 'config' }
        end, { desc = '[S]earch [N]eovim files' })    end
}
