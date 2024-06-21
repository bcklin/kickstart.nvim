print ("Loading custom keybinds")

--******************************************* My keybinds *******************************************
-- DAP keymap
vim.keymap.set('n', '<leader>dt', ':DapUiToggle<CR>', { desc = '[T]oggle DAP UI' })
vim.keymap.set('n', '<leader>db', ':DapToggleBreakpoint<CR>', { desc = 'Toggle [B]reakpoint' })
vim.keymap.set('n', '<leader>dc', ':DapContinue<CR>', { desc = 'DAP [C]ontinue' })
vim.keymap.set('n', '<leader>dr', ":lua require('dapui').open({reset=true})<CR>", { desc = 'DAP [R]eset windows' })

-- mbbill/undotree
vim.keymap.set('n', '<leader>du', ':UndotreeToggle<CR>', { desc = 'Toggle Undotree' })

-- telescope
vim.keymap.set('n', '<leader>dp', ':Telescope<CR>', { desc = 'Toggle Telescope' })  --Primeagen -> <C-p>
--***************************************************************************************************

-- Map arrow keys for insert mode. Temp disabled a couple of keybinds in luasnip for this.
vim.keymap.set('i', '<C-h>', '<left>', { desc = 'Move left in insert mode' })
vim.keymap.set('i', '<C-j>', '<down>', { desc = 'Move down in insert mode' })
vim.keymap.set('i', '<C-k>', '<up>', { desc = 'Move up in insert mode' })
vim.keymap.set('i', '<C-l>', '<right>', { desc = 'Move right in insert mode' })


-- Start plugins?
require('dapui').setup()
require('go').setup() -- see line 164, listed dependency
require('nvim-dap-virtual-text').setup()
require('null-ls').setup {
  debug = true,
}

local dap_ok, dap = pcall(require, 'dap')
if not dap_ok then
  print 'nvim-dap not installed!'
  return
end

require('dap').set_log_level 'INFO' -- Helps when configuring DAP, see logs with :DapShowLog
require('neodev').setup {
  library = { plugins = { 'nvim-dap-ui' }, types = true },
  ...,
}
dap.configurations = {
  go = {
    {
      type = 'go', -- Which adapter to use
      name = 'Debug', -- Human readable name
      request = 'launch', -- Whether to "launch" or "attach" to program
      program = '${file}', -- The buffer you are focused on when running nvim-dap
    },
    {
      type = 'go', -- Which adapter to use
      name = 'Debug Dir', -- Human readable name
      request = 'launch', -- Whether to "launch" or "attach" to program
      program = '${workspaceFolder}', -- The buffer you are focused on when running nvim-dap
    },
  },
}

dap.adapters.go = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.stdpath 'data' .. '/mason/bin/dlv',
    args = { 'dap', '-l', '127.0.0.1:${port}' },
  },
}

--Call goimports on save, see https://github.com/neovim/nvim-lspconfig/issues/115
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.go' },
  callback = function()
    local params = vim.lsp.util.make_range_params(nil, 'utf-16')
    params.context = { only = { 'source.organizeImports' } }
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, 'utf-16')
        else
          vim.lsp.buf.execute_command(r.command)
        end
      end
    end
  end,
})

-- Lua line icons using https://github.com/nvim-tree/nvim-web-devicons
--require('nvim-web-devicons').setup()

--Try to patch icons in DAP UI
-- Configuration from https://github.com/mortepau/codicons.nvim?tab=readme-ov-file#configuration
--require('codicons').setup {
-- Override by mapping name to icon
--  ['account'] = '?',
-- Or by name to hexadecimal/decimal value
--  ['comment'] = 0xEA6B, -- hexadecimal
--  ['archive'] = 60056, -- decimal
--}


return {}
