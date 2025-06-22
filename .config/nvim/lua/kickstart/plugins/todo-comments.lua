-- Highlight todo, notes, etc in comments
return {
    {
        'folke/todo-comments.nvim',
        event = 'VimEnter',
        dependencies = { 'nvim-lua/plenary.nvim' },
        opts = {
            signs = true,
            -- Define colours seperate to theme
            --colors = {
            --    error = { "#F7768E" },
            --    warning = { "#FAB387" },
            --    info = { "#7FC1FA", "bold", "underline"},
            --    hint = { "#9ECE6A" },
            --    default = { "#B4BEFE" },
            --    test = { "#DDB6F2" },
            --}
        },
    },
}
