-- setup
vim.g.mapleader      = ' '                                     -- leader
vim.g.maplocalleader = ' '                                     -- local leader

local map  = vim.keymap.set                                    -- keymap helper
local opts = { noremap = true, silent = true }                 -- default opts

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })       -- disable space

-- buffers
map('n', '<S-Tab>',    ':bprevious<CR>',           opts)       -- prev buffer
map('n', '<Tab>',      ':bnext<CR>',               opts)       -- next buffer
map('n', '<leader>b',  '<cmd>enew<CR>',            opts)       -- new buffer
map('n', '<leader>x',  ':bdelete!<CR>',            opts)       -- close buffer

-- delete / paste
map('n', 'x',          '"_x',                      opts)       -- delete no yank
map('v', 'p',          '"_dP',                     opts)       -- paste keep yank

-- diagnostics
map('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'prev diagnostic' })                             -- prev diagnostic

map('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'next diagnostic' })                             -- next diagnostic

map('n', '<leader>d', vim.diagnostic.open_float,
  { desc = 'diag float' })                                     -- float diagnostic

map('n', '<leader>q', vim.diagnostic.setloclist,
  { desc = 'diag list' })                                      -- list diagnostic

-- file
map('n', '<C-q>',      '<cmd>q<CR>',               opts)       -- quit
map('n', '<C-s>',      '<cmd>w<CR>',               opts)       -- write
map('n', '<leader>sn', '<cmd>noautocmd w<CR>',     opts)       -- write nofmt

-- resize
map('n', '<Down>',     ':resize +2<CR>',           opts)       -- grow height
map('n', '<Left>',     ':vertical resize -2<CR>',  opts)       -- shrink width
map('n', '<Right>',    ':vertical resize +2<CR>',  opts)       -- grow width
map('n', '<Up>',       ':resize -2<CR>',           opts)       -- shrink height

-- scrolling
map('n', '<C-d>',      '<C-d>zz',                  opts)       -- half-page down
map('n', '<C-u>',      '<C-u>zz',                  opts)       -- half-page up

-- search
map('n', 'N',          'Nzzzv',                    opts)       -- prev centered
map('n', 'n',          'nzzzv',                    opts)       -- next centered

-- split navigation
map('n', '<C-h>',      ':wincmd h<CR>',            opts)       -- focus left
map('n', '<C-j>',      ':wincmd j<CR>',            opts)       -- focus down
map('n', '<C-k>',      ':wincmd k<CR>',            opts)       -- focus up
map('n', '<C-l>',      ':wincmd l<CR>',            opts)       -- focus right

-- splits
map('n', '<leader>h',  '<C-w>s',                   opts)       -- split horizontal
map('n', '<leader>se', '<C-w>=',                   opts)       -- equalize
map('n', '<leader>v',  '<C-w>v',                   opts)       -- split vertical
map('n', '<leader>xs', ':close<CR>',               opts)       -- close split

-- tabs
map('n', '<leader>tn', ':tabn<CR>',                opts)       -- next tab
map('n', '<leader>to', ':tabnew<CR>',              opts)       -- new tab
map('n', '<leader>tp', ':tabp<CR>',                opts)       -- prev tab
map('n', '<leader>tx', ':tabclose<CR>',            opts)       -- close tab

-- visual indent
map('v', '<',          '<gv',                      opts)       -- indent left
map('v', '>',          '>gv',                      opts)       -- indent right

-- wrap
map('n', '<leader>lw', '<cmd>set wrap!<CR>',       opts)       -- toggle wrap
