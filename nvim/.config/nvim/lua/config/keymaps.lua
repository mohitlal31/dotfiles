-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Git browse file with line selection
vim.keymap.set({ "n", "v" }, "<leader>gf", function()
  require("snacks").gitbrowse({ what = "file" })
end, { desc = "Git Browse File" })

-- Copy file path
vim.keymap.set("n", "<leader>cp", function()
  local path = vim.fn.expand("%:p")
  vim.fn.setreg("+", path)
  print("Copied: " .. path)
end, { desc = "Copy file path" })
