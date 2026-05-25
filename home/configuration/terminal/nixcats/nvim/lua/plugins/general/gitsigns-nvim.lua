return {
  "gitsigns.nvim",
  enabled = nixCats('general') or false,
  event = "DeferredUIEnter",
  after = function (plugin)
    require('gitsigns').setup({
      -- See `:help gitsigns.txt`
      signs = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged = {
        add          = { text = '+' },
        change       = { text = '~' },
        delete       = { text = '_' },
        topdelete    = { text = '‾' },
        changedelete = { text = '~' },
        untracked    = { text = '┆' },
      },
      signs_staged_enabled = true,
      signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
      numhl      = false, -- Toggle with `:Gitsigns toggle_numhl`
      linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
      word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
      watch_gitdir = {
        follow_files = true
      },
      auto_attach = true,
      attach_to_untracked = false,
      current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
        virt_text_priority = 100,
        use_focus = true,
      },
      current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
      blame_formatter = nil, -- Use default
      sign_priority = 6,
      update_debounce = 100,
      status_formatter = nil, -- Use default
      max_file_length = 40000, -- Disable if file is longer than this (in lines)
      preview_config = {
        -- Options passed to nvim_open_win
        style = 'minimal',
        relative = 'cursor',
        row = 0,
        col = 1
      },
      on_attach = function(bufnr)
        -- local gitsigns = package.loaded.gitsigns
        --
        -- local function map(mode, l, r, opts)
        --   opts = opts or {}
        --   opts.buffer = bufnr
        --   vim.keymap.set(mode, l, r, opts)
        -- end
        --
        -- -- Navigation
        -- map({ 'n', 'v' }, ']c', function()
        --   if vim.wo.diff then
        --     return ']c'
        --   end
        --   vim.schedule(function()
        --     gitsigns.next_hunk()
        --   end)
        --   return '<Ignore>'
        -- end, { expr = true, desc = 'Jump to next hunk' })
        --
        -- map({ 'n', 'v' }, '[c', function()
        --   if vim.wo.diff then
        --     return '[c'
        --   end
        --   vim.schedule(function()
        --     gitsigns.prev_hunk()
        --   end)
        --   return '<Ignore>'
        -- end, { expr = true, desc = 'Jump to previous hunk' })
        --
        -- -- Actions
        -- -- visual mode
        -- map('v', '<leader>hs', function() gitsigns.stage_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'stage git hunk' })
        -- map('v', '<leader>hr', function() gitsigns.reset_hunk { vim.fn.line '.', vim.fn.line 'v' } end, { desc = 'reset git hunk' })
        -- -- normal mode
        -- map('n', '<leader>gs', gitsigns.stage_hunk, { desc = 'git stage hunk' })
        -- map('n', '<leader>gr', gitsigns.reset_hunk, { desc = 'git reset hunk' })
        -- map('n', '<leader>gS', gitsigns.stage_buffer, { desc = 'git Stage buffer' })
        -- map('n', '<leader>gu', gitsigns.undo_stage_hunk, { desc = 'undo stage hunk' })
        -- map('n', '<leader>gR', gitsigns.reset_buffer, { desc = 'git Reset buffer' })
        -- map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'preview git hunk' })
        -- map('n', '<leader>gb', function() gitsigns.blame_line { full = false } end, { desc = 'git blame line' })
        -- map('n', '<leader>gd', gitsigns.diffthis, { desc = 'git diff against index' })
        -- map('n', '<leader>gD', function() gitsigns.diffthis '~' end, { desc = 'git diff against last commit' })
        -- -- Toggles
        -- map('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = 'toggle git blame line' })
        -- map('n', '<leader>gtd', gitsigns.toggle_deleted, { desc = 'toggle git show deleted' })
        -- -- Text object
        -- map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
      end,
    })
  end,
}
