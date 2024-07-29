require('ibl').setup({
  indent = {
    -- highlight = { "Function", "Label" },
    -- highlight = {"CursorColumn", "Whitespace"},
    char = "▏",
    priority = 2,
    repeat_linebreak = false,
  },
  whitespace = {
    -- highlight = { "Function", "Label" },
    remove_blankline_trail = true,
  },
  scope = {
    -- highlight = { "Function", "Label" },
    char = "▎",
    show_start = false,
    show_end = false,
    show_exact_scope = true,
    include = {
      node_type = { ["*"] = { "*" } },
    },
    exclude = {},
  },
})

