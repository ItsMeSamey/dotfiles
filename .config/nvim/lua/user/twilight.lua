require('twilight').setup({
  dimming = {
    -- alpha = 0.45,
    -- color = { "Normal", "#ffffff" },
    term_bg = "#000000",
    inactive = false,
  },
  context = 10,
  treesitter = true,
  expand = {
    -- "function",
    -- "method",
    -- "table",
    -- "if_statement",
    -- "*",
  },
  exclude = {},
})

