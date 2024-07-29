vim.cmd('tnoremap <Esc> <C-\\><C-n>')
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- vim.opt.swapfile = false
-- vim.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.cache/nvim/undodir/'
vim.opt.undofile = true

vim.g.markdown_folding = 1

vim.opt.foldcolumn = '0'
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true

vim.opt.cmdheight = 0
vim.opt.wrap = false

vim.opt.scrolloff = 3
-- Keep signcolumn on by default
vim.wo.signcolumn = 'yes'
-- vim.opt.isfname:append('@-@')

vim.opt.relativenumber = true

-- Make line numbers default
vim.wo.number = true
vim.opt.nu = true

-- indenting
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
-- vim.opt.smartindent = true

-- search
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- [[ Setting options ]]
-- See `:help vim.o`
-- NOTE: You can change these options as you wish!

-- Enable mouse mode
-- vim.o.mouse = 'a'

-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.o.clipboard = 'unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Decrease update time
vim.o.updatetime = 150
vim.o.timeoutlen = 250

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone,noselect'

vim.o.termguicolors = true

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})

-- vim.filetype.add({pattern = { [".*"] = "txt" },})
vim.filetype.add({ pattern = { [".*config/hypr/.*conf"] = "hyprlang" } })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
-- vim.opt.spell = true
-- vim.opt.spelllang = { 'en_us' }
vim.g.zig_fmt_autosave = 0
require 'user'
require 'user.cmp'
require 'user.mason'

require 'user.theme'
require 'user.treesitter'
require 'user.twilight'
require 'user.gitsigns'
require 'user.indent'
require 'user.ufo'

-- require 'user.flutter'
-- require 'user.comment'
require('autoclose').setup()

require 'user.telescope'
-- require 'user.which-key'

require 'user.remaps'

