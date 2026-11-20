# terminil.nvim

_A simple plugin that makes interacting with the terminal easier._

## Features

- **Reopen the hidden terminal window while retaining the window configuration**
- **Many default keymaps make interacting with the terminal simpler**
- **Open the terminal and configure your own window**
- **Provides many useful functions**
- **Floating terminal window**
- **Highly customizable**
- **Toggle the terminal**
- _etc_.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    'X3ru4/terminil.nvim',
    event = 'VeryLazy',
    config = function()
        require('terminil').setup()
    end
}
```

With vim.pack

```lua
vim.pack.add({ 'https://github.com/X3ru4/terminil.nvim' })
require('terminil').setup()
```

## Configuration

[Default configuration](https://github.com/X3ru4/terminil.nvim/blob/main/lua/terminil.lua#L33-L96)

## Docs

### [APIs](https://github.com/X3ru4/terminil.nvim/blob/main/APIs.md)

### Global variable

This variable will be set when the `setup()` function is run.

```lua
_G.tnil = require('terminil')
```

### Terminal in floating window

```lua
vim.keymap.set('n', '<leader>tf', function()
    local width = tnil.h.size('width', 0.7)
    local height = tnil.h.size('height', 0.6)
    tnil.open({
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
    tnil.open({ split = 'below' }, {
        cmd = { 'git status', 'fzf' }, -- or 'git status'
    })
end)
```

### Give the terminal a custom name using the `buf_call` function

```lua
tnil.open(nil, {
    buf_call = function(buf)
        vim.api.nvim_buf_set_name(buf, 'Terminil hihi')
    end,
})
```

### Open with a different shell

```lua
tnil.open(nil, { shell = 'zsh' })
```

### Keymaps

```lua
local buf = nil
tnil.setup({
    keys = {
        -- Set it to false to disable keymap
        ['<C-t>t'] = false,
        -- Create your own keymaps. See: vim.keymap.set()
        ['<M-/>'] = {
            function() -- rhs
                if not buf or not tnil.h.is_term(buf) then
                    local data = tnil.open({
                        split = 'below',
                    })
                    buf = data.buf
                else
                    tnil.toggle_buf(buf)
                end
            end,
            mode = { 'n', 't' }, -- Default: mode = 't'
            -- opts
            desc = 'Toggle below terminal',
        },
    },
    -- Set it to false if you want to disable all default keymaps
    use_default_keys = true,
})
```

### Open multiple windows at the same time

```lua
tnil.open_multiple(count?, cycle?, opts?)
```

Split according to your style, and it will repeat your configuration in cycles.

```lua
tnil.open_multiple(5, { 'above', { split = 'left', width = 10 }, 'right' })
```

### Add more terminals

```lua
tnil.add(count?: integer, open?: boolean)

tnil.add(3)
```

By default, `count` will use the variable vim.v.count1 as the default.

```lua
tnil.add()
```

### Switch between terminals and move to different windows

Most functions use the count prefix

```lua
-- Switch to a different terminal in the current window
tnil.switch(-1) -- switch to the previous terminal
tnil.switch(1)  -- switch to the next terminal

tnil.focus(-1)  -- Jump to the previous terminal window
tnil.focus(1)   -- Jump to the next terminal window
```

Use indexes for control

```lua
tnil.switch_in_order(idx?: integer)
tnil.open_in_order(idx?: integer)

-- For example: If you hide a window or terminal and it has the number 1
-- then you press the key combination `1<leader>tt` and it will open the terminal.
vim.keymap.set('n', '<leader>tt', tnil.open_in_order)
```

### Hide and close the terminal

```lua
tnil.hide(buf?: integer)
tnil.close(buf?: integer)
```

### Toggle terminal

```lua
tnil.toggle('current')  -- Toggle current terminal
tnil.toggle('previous') -- Toggle previous terminal
tnil.toggle_buf(buf: integer)    -- Toggle terminal buf
```

- Default keymaps
  - `<A-_>` Toggle previous terminal
  - `<C-_>` Toggle current terminal

### Select a terminal

```lua
-- Use the `vim.ui.select` or `ui_select` function to display all terminals
-- and select one.
-- You can use a different vim.ui.select() function via `ui_select`
-- behavior:
-- |'open'   Open terminal.
-- |'switch' Open the selected terminal in the current window.
-- |'close'  Close the selected terminal.
tnil.select(behavior?: 'open'|'switch'|'close', ui_select?)
```

### Termonly

Similar to the `tabonly` command. See `:tabonly`

```lua
-- `behavior` default is 'hide'. Be careful when using 'close'.
-- 'buf'      default is current buffer
tnil.termonly(behavior?: 'close'|'hide', buf?: integer)
```
