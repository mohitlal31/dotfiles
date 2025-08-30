return {
    'ellisonleao/gruvbox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
        -- Initial theme settings
        local bg_transparent = true

        vim.o.background = 'dark' -- or "light" if you prefer light mode

        require('gruvbox').setup {
            contrast = 'hard',
            transparent_mode = bg_transparent,
        }

        vim.cmd [[colorscheme gruvbox]]

        -- Toggle transparency on <leader>bg
        local toggle_transparency = function()
            bg_transparent = not bg_transparent
            require('gruvbox').setup {
                transparent_mode = bg_transparent,
            }
            vim.cmd [[colorscheme gruvbox]]
        end

        vim.keymap.set('n', '<leader>bg', toggle_transparency, { noremap = true, silent = true, desc = 'Toggle background transparency' })
    end,
}
