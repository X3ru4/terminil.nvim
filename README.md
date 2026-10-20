# terminil.nvim

## A simple plugin that makes interacting with the terminal easier.

### Installation

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

### Configuration

- Default configuration

```lua
M.config = {
    use_default_keys = true,
    keys = {
        ['<C-w>c'] = { '<cmd>hide<cr>', desc = 'Hide the window' },
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
}
```
