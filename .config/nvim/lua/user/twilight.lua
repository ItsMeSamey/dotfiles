require('twilight').setup({
  dimming = {
    -- alpha = 0.45,
    -- color = { "Normal", "#ffffff" },
    term_bg = "#000000",
    inactive = false,
  },
  context = 1,
  treesitter = false,
  expand = {
    -- "function",
    -- "method",
    -- "table",
    -- "if_statement",
    -- "*",
  },
  exclude = {},
})

