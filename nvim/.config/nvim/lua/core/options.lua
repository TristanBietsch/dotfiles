-- diagnostics / messages
vim.o.showmode                  = false                      -- hide mode text
vim.opt.shortmess:append 'c'                                 -- quiet completion

-- editing
vim.o.autoindent                = true                       -- inherit indent
vim.o.completeopt               = 'menuone,noselect'         -- completion mode
vim.o.expandtab                 = true                       -- tabs → spaces
vim.o.shiftwidth                = 4                          -- indent size
vim.o.smartindent               = true                       -- smart indent
vim.o.softtabstop               = 4                          -- edit width
vim.o.tabstop                   = 4                          -- tab width

-- editing modes
vim.opt.formatoptions:remove { 'c', 'r', 'o' }               -- no auto comments
vim.opt.iskeyword:append '-'                                 -- treat hyphen as word

-- files
vim.o.backup                    = false                      -- no backup
vim.o.fileencoding              = 'utf-8'                    -- encoding
vim.o.swapfile                  = false                      -- no swapfile
vim.o.undofile                  = true                       -- undo file
vim.o.writebackup               = false                      -- no write backup

-- misc
vim.o.backspace                 = 'indent,eol,start'         -- backspace anywhere
vim.o.breakindent               = true                       -- break indent
vim.o.clipboard                 = 'unnamedplus'              -- OS clipboard
vim.o.cmdheight                 = 1                          -- cmd height
vim.o.conceallevel              = 0                          -- no conceal
vim.o.mouse                     = 'a'                        -- mouse
vim.o.pumheight                 = 10                         -- popup size

-- movement
vim.o.ignorecase                = true                       -- ignore case
vim.o.scrolloff                 = 4                          -- cursor margin
vim.o.sidescrolloff             = 8                          -- horizontal margin
vim.o.smartcase                 = true                       -- smart case
vim.o.timeoutlen                = 300                        -- map timeout
vim.o.updatetime                = 250                        -- faster updates
vim.o.whichwrap                 = 'bs<>[]hl'                 -- wrap keys

-- runtime
vim.opt.runtimepath:remove '/usr/share/vim/vimfiles'         -- no Vim runtime

-- search
vim.o.hlsearch                  = false                      -- no highlights

-- splits
vim.o.showtabline               = 2                          -- tabs
vim.o.splitbelow                = true                       -- splits below
vim.o.splitright                = true                       -- splits right

-- ui
vim.o.cursorline                = false                      -- no highlight
vim.o.linebreak                 = true                       -- natural breaks
vim.o.numberwidth               = 4                          -- number gutter
vim.opt.termguicolors           = true                       -- truecolor
vim.o.wrap                      = false                      -- no wrap
vim.wo.number                   = true                       -- line numbers
vim.opt.relativenumber          = true                       -- relative numbers
vim.wo.signcolumn               = 'yes'                      -- sign column
