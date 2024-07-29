-- Mypref
vim.keymap.set('n', '<leader>e', vim.cmd.Ex)
vim.keymap.set('n', '<leader>w', vim.cmd.w)
vim.keymap.set('n', '<leader>x', vim.cmd.x)
vim.keymap.set('n', '<leader>bb', vim.cmd.bnext)
vim.keymap.set('n', '<leader>bn', vim.cmd.bprevious)
vim.keymap.set('n', '<leader>bi', vim.cmd.buffers)
vim.keymap.set('n', '<leader>z', vim.cmd.bd)
vim.keymap.set('n', '<leader>b1', function() vim.cmd('b1') end)
vim.keymap.set('n', '<leader>b2', function() vim.cmd('b2') end)
vim.keymap.set('n', '<leader>b3', function() vim.cmd('b3') end)
vim.keymap.set('n', '<leader>b4', function() vim.cmd('b4') end)
vim.keymap.set('n', '<leader>b5', function() vim.cmd('b5') end)
vim.keymap.set('n', '<leader>b6', function() vim.cmd('b6') end)
vim.keymap.set('n', '<leader>b7', function() vim.cmd('b7') end)
vim.keymap.set('n', '<leader>b8', function() vim.cmd('b8') end)
vim.keymap.set('n', '<leader>b9', function() vim.cmd('b9') end)
vim.keymap.set('n', '<leader>b0', function() vim.cmd('b10') end)
vim.keymap.set('n', '<leader>t', function() vim.cmd('Twilight') end)

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>f', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

local function telescope_live_grep_open_files()
  require('telescope.builtin').live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end

-- Telescope
vim.keymap.set('n', '<leader>s/', telescope_live_grep_open_files, { desc = '[S]earch [/] in Open Files' })
vim.keymap.set('n', '<leader>ss', require('telescope.builtin').builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sG', ':LiveGrepGitRoot<cr>', { desc = '[S]earch by [G]rep on Git Root' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- UFO
vim.keymap.set('n', 'zR', require('ufo').openAllFolds)
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds)

-- UndoTree
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)



