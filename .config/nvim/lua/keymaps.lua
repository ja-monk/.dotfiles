-- [[ Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Easier shortcut to  exit terminal mode, otherwise would be <C-\><C-n>
-- NOTE: This won't work in all terminal emulators/tmux/etc
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode to force hjkl navigation
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier
--  See `:help wincmd` for a list of all window commands
-- Use CTRL+<hjkl> to switch between windows
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
-- Keybinds for moving nvim windows
-- NOTE: Some terminals have colliding keymaps or are not able to send distinct keycodes
-- vim.keymap.set("n", "<C-S-h>", "<C-w>H", { desc = "Move window to the left" })
-- vim.keymap.set("n", "<C-S-l>", "<C-w>L", { desc = "Move window to the right" })
-- vim.keymap.set("n", "<C-S-j>", "<C-w>J", { desc = "Move window to the lower" })
-- vim.keymap.set("n", "<C-S-k>", "<C-w>K", { desc = "Move window to the upper" })

-- Show LSP diagnostic messages in floating window
vim.keymap.set('n', 'gs', '<cmd>lua vim.diagnostic.open_float()<CR>', { desc = 'Show LSP diagnostic message'})

-- Reload LSP
vim.keymap.set('n', 'grl', '<cmd>LspRestart<CR>', {desc = 'LSP [R]e[L]oad'})

-- create command to copy full or relative file path to clipboard
vim.api.nvim_create_user_command('CopyFilePath', function(opts)
    local path
        if opts.args == "r" then            -- pass r for relative path
            path = vim.fn.expand('%')
        else
            path = vim.fn.expand('%:p')     -- else full path
        end
    vim.fn.setreg('+', path)                -- copy to system clipboard
    print("Copied to clipboard: " .. path)
end, { nargs = "?" })
-- keymap for command that copied path
vim.keymap.set('n', '<leader>cp', '<cmd>CopyFilePath<CR>', {desc = '[C]opy full [P]ath to clipboard'})
vim.keymap.set('n', '<leader>cr', '<cmd>:CopyFilePath r<CR>', {desc = '[C]opy [R]elative path to clipboard'})

-- [[ Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text, e.g. with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
    callback = function()
        vim.hl.on_yank()
    end,
})
