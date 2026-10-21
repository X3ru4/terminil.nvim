# terminil.nvim

A simple plugin that makes interacting with the terminal easier.

## Installation

With vim.pack

```lua
vim.pack.add({ 'https://github.com/X3ru4/terminil.nvim' })
require('terminil').setup()
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    'X3ru4/terminil.nvim',
    event = 'VeryLazy',
    ---@module 'terminil'
    ---@type terminil.opts
    opts = {},
}
```

## Cooking recipes

### Terminal in floating window

```lua
local terminil = require('terminil')
vim.keymap.set('n', '<leader>tf', function()
    local width = terminil.helper.size('width', 0.7)
    local height = terminil.helper.size('height', 0.6)
    terminil.open({
        relative = 'editor',
        title = ' >_ Terminal ',
        title_pos = 'center',
        width = width,
        height = height,
        -- Center the floating window.
        row = math.ceil((vim.o.lines - height) / 2) - 2,
        col = math.ceil((vim.o.columns - width) / 2),
    })
end)
```

### Run shell commands when the terminal window is open

```lua
vim.keymap.set('n', '...', function()
    local width = terminil.helper.size('width', 0.7)
    local height = terminil.helper.size('height', 0.6)
    terminil.open({
        relative = 'editor',
        title = ' >_ Terminal ',
        title_pos = 'center',
        width = width,
        height = height,
        -- Center the floating window.
        row = math.ceil((vim.o.lines - height) / 2) - 2,
        col = math.ceil((vim.o.columns - width) / 2),
    }, {
        cmd = { 'git status', 'fzf' }, -- or 'git status'
    })
end)
```

## Configuration

Default configuration

```lua
M.config = {
    use_default_keys = true,
    keys = {
        ['<C-w>e'] = { '<cmd>hide<cr>', desc = 'Hide the window' },
        ['<C-w>c'] = { '<cmd>silent! bdelete!<cr>', desc = 'Delete the terminal' },
        ['<C-w>s'] = { '<cmd>stopinsert<cr>', desc = 'Stop insert in terminal mode' },
        ['<C-w>n'] = {
            function()
                vim.ui.input({ prompt = 'New name: ' }, function(input)
                    if not input then
                        return
                    end
                    vim.api.nvim_buf_set_name(0, input)
                end)
            end,
            desc = 'Remame the terminal',
        },
        ['<leader>tt'] = { '<cmd>terminal<cr>i', mode = 'n', desc = 'Open new terminal' },
        ['<leader>th'] = {
            function()
                M.open({ split = vim.o.splitbelow and 'below' or 'above' })
            end,
            mode = 'n',
            desc = 'Open new split terminal',
        },
        ['<leader>tv'] = {
            function()
                M.open({ split = vim.o.splitright and 'right' or 'left' })
            end,
            mode = 'n',
            desc = 'Open new vsplit terminal',
        },
        ['<leader>ts'] = {
            function()
                M.select()
            end,
            mode = 'n',
            desc = 'Select terminal',
        },
    },
    win_config = {
        split = 'below',
    },
    buflisted = false,
}
```
