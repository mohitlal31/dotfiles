return {
  "mattn/vim-gist",
  dependencies = { "mattn/webapi-vim" },
  config = function()
    vim.g.github_api_url = "https://github.marqeta.com/api/v3"
    vim.g.gist_api_url = "https://github.marqeta.com/api/v3"
    vim.g.gist_clip_command = "pbcopy"
    vim.g.gist_detect_filetype = 1
    vim.g.gist_open_browser_after_post = 1
    
    -- Use environment variable or GitHub CLI token
    vim.g.gist_token = os.getenv("GITHUB_TOKEN") or vim.fn.system("gh auth token --hostname github.marqeta.com"):gsub("%s+", "")
    
    -- Keybindings
    vim.keymap.set("n", "<leader>Gf", ":Gist<CR>", { desc = "Create gist from file" })
    vim.keymap.set("v", "<leader>Gs", ":Gist<CR>", { desc = "Create gist from selection" })
  end,
}
