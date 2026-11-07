# terminil.nvim

_A simple plugin that makes interacting with the terminal easier._

## Features

- **Open the terminal and configure your own window**
- **Reopen the hidden terminal window while retaining the window configuration**
- **Many default keymaps make interacting with the terminal simpler**
- **Provides several useful helper functions**
- **Floating terminal window**
- **Highly customizable**

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    'X3ru4/terminil.nvim',
    event = 'VeryLazy',
    init = function()
        -- Change the prefix of the default keymaps.
        vim.g.tnil_keyprefix_n = 'gt'    -- Default: '<leader>t'
        vim.g.tnil_keyprefix_t = '<C-t>' -- Default: '<C-t>'
    end,
    ---@module 'terminil'
    ---@type terminil.opts
    opts = {},
}
```

With vim.pack

```lua
vim.pack.add({ 'https://github.com/X3ru4/terminil.nvim' })
-- Change the prefix of the default keymaps.
vim.g.tnil_keyprefix_n = 'gt'    -- Default: '<leader>t'
vim.g.tnil_keyprefix_t = '<C-t>' -- Default: '<C-t>'
require('terminil').setup()
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
    terminil.open({ split = 'below' }, {
        cmd = { 'git status', 'fzf' }, -- or 'git status'
    })
end)
```

### Give the terminal a custom name using the `buf_call` function

```lua
terminil.open(nil, {
    buf_call = function(buf)
        vim.api.nvim_buf_set_name(buf, 'Terminil hihi')
    end,
})
```

### Open with a different shell

```lua
terminil.open(nil, { shell = 'zsh' })
```

### Disable default keymaps

```lua
terminil.setup({
    keys = {
        ['<leader>tf'] = false,
        ['<leader>th'] = false,
        ['<leader>tv'] = false,
    }
})
```

### Open multiple windows at the same time

```lua
terminil.open_multiple(3)
```

Split in your own style

```lua
terminil.open_multiple(5, { 'above', { split = 'left', width = 10 }, 'right' })
```

### Switch between terminals and move to different windows

Most functions use the count prefix

```lua
-- Switch to a different terminal in the current window
terminil.switch(-1) -- switch to the previous terminal
terminil.switch(1) -- switch to the next terminal

terminil.focus(-1) -- Jump to the previous terminal window
terminil.focus(1) -- Jump to the next terminal window
```

Use indexes for control

```lua
terminil.switch_in_order(idx?)
terminil.open_in_order(idx?)

-- For example: If you hide a window or terminal and it has the number 1
-- then you press the key combination `1<leader>tw` and it will open the terminal.
vim.keymap.set('n', '<leader>tt', terminil.open_in_order)
```

### Hide and close the terminal

```lua
terminil.hide(idx?)
terminil.close(buf?)
```

### Toggle terminal

```lua
terminil.toggle('current') -- Toggle current terminal
terminil.toggle('previous') -- Toggle previous terminal
terminil.toggle_buf(buf) -- Toggle terminal buf
```

- Default keymaps
  - `<A-_>` Toggle previous terminal
  - `<C-_>` Toggle current terminal

## Configuration

[Default configuration](https://github.com/X3ru4/terminil.nvim/blob/main/lua/terminil.lua#L36-L187)
