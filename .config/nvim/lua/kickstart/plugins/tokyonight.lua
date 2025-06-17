return {
  { -- NOTE: To change to a different colorscheme:
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.

    -- to see colorschemes already installed use `:Telescope colorscheme`.
    'folke/tokyonight.nvim',
    priority = 1000, -- Make sure to load this before all the other start plugins.
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('tokyonight').setup {
        styles = {
          comments = { italic = false }, -- Disable italics in comments
        },
        -- change background on theme to match terminal theme
        --on_colors = function(colors)
        --  colors.bg = '#2c2c2c'
        --end,
      }

      -- Load the colorscheme here.
      -- Tokyo-night has multiple styles: 'tokyonight-night', 'tokyonight-storm', 'tokyonight-moon', 'tokyonight-day'
      vim.cmd.colorscheme 'tokyonight-night'
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
