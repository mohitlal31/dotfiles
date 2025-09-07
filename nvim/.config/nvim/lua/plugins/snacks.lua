return {
  "folke/snacks.nvim",
  opts = {
    gitbrowse = {
      url_patterns = {
        ["github%.marqeta%.com"] = {
          branch = "/tree/{branch}",
          file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
          permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
          commit = "/commit/{commit}",
        }
      }
    }
  }
}
