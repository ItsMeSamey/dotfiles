local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    '--depth=1',
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- `:help lazy.nvim.txt` for more info
--  You can configure plugins using the `config` key.
--  You can also configure plugins after the setup call, as they will be available in your neovim runtime.
require('lazy').setup({
  -- The undo-tree
  'mbbill/undotree',

  -- Display man pages
  'vim-utils/vim-man',

  -- Autoclose bracket pairs
  'm4xshen/autoclose.nvim',

  -- Twilight for focus mode
  "folke/twilight.nvim",

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',

  -- Useful plugin to show you pending keybinds.
  { 'folke/which-key.nvim', opts = {} },

  -- 'gc' to comment visual regions/lines
  -- { 'numToStr/Comment.nvim', opts = {} },

  -- Git related plugins
  -- 'tpope/vim-fugitive',
  -- 'tpope/vim-rhubarb',

  -- Java plugin
  "mfussenegger/nvim-jdtls",

  {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' }
  },

  { -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- See `:help ibl`
    main = 'ibl',
  },

  { -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    lazy = false,
  },

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    build = ':TSUpdate',
  },

  -- {
  --   'akinsho/flutter-tools.nvim',
  --   lazy = false,
  --   dependencies = {
  --     'nvim-lua/plenary.nvim',
  --     'stevearc/dressing.nvim', -- optional for vim.ui.select
  --   },
  --   config = true,
  -- },

  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    opts = {
      options = {
        icons_enabled = true,
        theme = 'auto',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
      -- Automatically install LSPs to stdpath for neovim
      {
        'williamboman/mason.nvim',
        -- config = true
      },
      'williamboman/mason-lspconfig.nvim',
      -- Useful status updates for LSP
      -- NOTE: `opts = {}` is the same as calling `require('fidget').setup({})`
      -- { 'j-hui/fidget.nvim', opts = {} },
      -- Additional lua configuration, makes nvim stuff amazing!
      'folke/neodev.nvim',
    },
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      -- Fuzzy Finder Algorithm which requires local dependencies to be built.
      -- Only load if `make` is available. Make sure you have the system
      -- requirements installed.
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        -- NOTE: If you are having trouble with this installation,
        --       refer to the README for telescope-fzf-native for more instructions.
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
  },

  {
    "luckasRanarison/tailwind-tools.nvim",
    name = "tailwind-tools",
    build = ":UpdateRemotePlugins",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-telescope/telescope.nvim", -- optional
      "neovim/nvim-lspconfig", -- optional
    },
    opts = {} -- your configuration
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function() return 'make install_jsregexp' end)(),
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds LSP completion capabilities
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',

      -- Adds a number of user-friendly snippets
      'rafamadriz/friendly-snippets',

      -- Custom Sources
      'hrsh7th/cmp-calc',
      'hrsh7th/cmp-buffer',
      'f3fora/cmp-spell',

      -- Clangd
      'p00f/clangd_extensions.nvim'
    },
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<M-]>",
          clear_suggestion = "<M-[>",
          accept_word = "<M-j>",
        },
        log_level = "off", --can be "info"
        disable_inline_completion = false,
        disable_keymaps = false,
        -- condition = function()
        --   return false -- returns is-disabled
        -- end
      })
    end,
  },

  -- {
  --   "zbirenbaum/copilot.lua",
  --   config = function ()
  --     require("copilot").setup({
  --       panel = {
  --         enabled = false,
  --         auto_refresh = true,
  --         keymap = {
  --           jump_prev = "[[",
  --           jump_next = "]]",
  --           accept = "<CR>",
  --           refresh = "gr",
  --           open = "<M-CR>"
  --         },
  --         layout = {
  --           position = "bottom", -- | top | left | right
  --           ratio = 0.4
  --         },
  --       },
  --       suggestion = {
  --         enabled = true,
  --         auto_trigger = true,
  --         debounce = 75,
  --         keymap = {
  --           accept = "<M-l>",
  --           accept_word = false,
  --           accept_line = false,
  --           next = "<M-]>",
  --           prev = "<M-[>",
  --           dismiss = "<C-]>",
  --         },
  --       },
  --       filetypes = {
  --         yaml = false,
  --         markdown = false,
  --         help = false,
  --         gitcommit = false,
  --         gitrebase = false,
  --         hgcommit = false,
  --         svn = false,
  --         cvs = false,
  --         ["."] = false,
  --       },
  --       copilot_node_command = 'node', -- Node.js version must be > 18.x
  --       server_opts_overrides = {},
  --     })
  --   end
  -- },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   config = function ()
  --     require("copilot_cmp").setup({
  --       suggestion = { enabled = false },
  --       panel = { enabled = false },
  --     })
  --   end
  -- },
}, {})

