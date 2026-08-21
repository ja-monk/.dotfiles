-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update

-- Plugins added in the below "require" block
require('lazy').setup({
    -- The import below automatically adds plugins, configuration, etc from `lua/plugins/*.lua`
    -- to disable a plugin set `enabled = false` in the returned table in it's .lua file
    { import = 'plugins' },

    -- Additional plugins can be explicitly required like below
    --require 'plugins.indent_line',
    --require 'plugins.lint',
    --require 'plugins.autopairs',
    --require 'plugins.neo-tree',
}, {
    ui = {
        -- If you are using a Nerd Font: set icons to an empty table which will use the
        -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
        icons = vim.g.have_nerd_font and {} or {
            cmd = '⌘',
            config = '🛠',
            event = '📅',
            ft = '📂',
            init = '⚙',
            keys = '🗝',
            plugin = '🔌',
            runtime = '💻',
            require = '🌙',
            source = '📄',
            start = '🚀',
            task = '📌',
            lazy = '💤 ',
        },
    },
})

-- vim: ts=2 sts=2 sw=2 et
