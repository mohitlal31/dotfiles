-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Show trailing whitespace and tabs
vim.opt.list = true
vim.opt.listchars = { trail = "·", tab = "→ " }

-- Set colors for whitespace only (don't touch NonText to preserve indent lines)
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Whitespace", { fg = "#ff5555" })
  end,
})

-- Apply colors immediately
vim.api.nvim_set_hl(0, "Whitespace", { fg = "#ff5555" })
