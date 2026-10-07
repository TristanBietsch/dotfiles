local markdown_injections_012_workaround = [[
((html_block) @injection.content
  (#set! injection.language "html")
  (#set! injection.combined)
  (#set! injection.include-children))

((minus_metadata) @injection.content
  (#set! injection.language "yaml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

((plus_metadata) @injection.content
  (#set! injection.language "toml")
  (#offset! @injection.content 1 0 -1 0)
  (#set! injection.include-children))

([
  (inline)
  (pipe_table_cell)
] @injection.content
  (#set! injection.language "markdown_inline"))
]]

return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  init = function()
    -- Neovim 0.12 currently crashes on fenced-code markdown injections.
    if vim.fn.has('nvim-0.12') == 1 then
      vim.treesitter.query.set('markdown', 'injections', markdown_injections_012_workaround)
    end
  end,
  config = function(_, opts)
    require('nvim-treesitter.configs').setup(opts)

    -- nvim 0.12 changed the query-match format: match[capture_id] is now
    -- TSNode[] instead of TSNode. nvim-treesitter (master) hasn't been
    -- updated, so its custom directives crash on injection parsing with
    -- "attempt to call method 'range' (a nil value)". Re-register the
    -- affected directives with a shim that unwraps the node list.
    if vim.fn.has('nvim-0.12') == 1 then
      local query = vim.treesitter.query
      local opts_force = { force = true, all = false }

      local function first_node(match, capture_id)
        local n = match[capture_id]
        if type(n) == 'table' then n = n[1] end
        return n
      end

      local html_script_type_languages = {
        ['text/javascript'] = 'javascript',
        ['text/x-typescript'] = 'typescript',
      }

      local markdown_aliases = {
        sh = 'bash', shell = 'bash', zsh = 'bash',
        js = 'javascript', ts = 'typescript', py = 'python',
        rs = 'rust', md = 'markdown',
      }

      query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
        local node = first_node(match, pred[2])
        if not node then return end
        local alias = vim.treesitter.get_node_text(node, bufnr):lower()
        metadata['injection.language'] = markdown_aliases[alias] or alias
      end, opts_force)

      query.add_directive('set-lang-from-mimetype!', function(match, _, bufnr, pred, metadata)
        local node = first_node(match, pred[2])
        if not node then return end
        local val = vim.treesitter.get_node_text(node, bufnr)
        local configured = html_script_type_languages[val]
        if configured then
          metadata['injection.language'] = configured
        else
          local parts = vim.split(val, '/', {})
          metadata['injection.language'] = parts[#parts]
        end
      end, opts_force)

      query.add_directive('downcase!', function(match, _, bufnr, pred, metadata)
        local id = pred[2]
        local node = first_node(match, id)
        if not node then return end
        local text = vim.treesitter.get_node_text(node, bufnr, { metadata = metadata[id] }) or ''
        if not metadata[id] then metadata[id] = {} end
        metadata[id].text = string.lower(text)
      end, opts_force)
    end
  end,
  -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
  opts = {
    ensure_installed = {
      'lua',
      'python',
      'javascript',
      'typescript',
      'vimdoc',
      'vim',
      'regex',
      'terraform',
      'sql',
      'dockerfile',
      'toml',
      'json',
      'java',
      'groovy',
      'go',
      'gitignore',
      'graphql',
      'yaml',
      'make',
      'cmake',
      'markdown',
      'markdown_inline',
      'bash',
      'tsx',
      'css',
      'html',
      'rust', 
      'elixir', 
      'ruby', 
      'proto',
      'hcl',
      'c',
      'bash',
      'prisma',
      'dot',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = { enable = true, disable = { 'ruby' } },
  },
  -- There are additional nvim-treesitter modules that you can use to interact
  -- with nvim-treesitter. You should go explore a few and see what interests you:
  --
  --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
  --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
  --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
}
