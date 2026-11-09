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
- **Rename the terminal**
- _etc_.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
return {
    'X3ru4/terminil.nvim',
    event = 'VeryLazy',
    init = function()
        -- Change the prefix of the default keymaps.
        vim.g.tnil_keyprefix_n = 'gt'    -- For normal mode   Default: '<leader>t'
        vim.g.tnil_keyprefix_t = '<C-t>' -- For terminal mode Default: '<C-t>'
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
vim.g.tnil_keyprefix_n = 'gt'    -- For normal mode   Default: '<leader>t'
vim.g.tnil_keyprefix_t = '<C-t>' -- For terminal mode Default: '<C-t>'
require('terminil').setup()
```

## Configuration

[Default configuration](https://github.com/X3ru4/terminil.nvim/blob/main/lua/terminil.lua#L36-L239)

## Docs

### Terminal in floating window

```lua
local terminil = require('terminil')
vim.keymap.set('n', '<leader>tf', function()
    local width = terminil.h.size('width', 0.7)
    local height = terminil.h.size('height', 0.6)
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

### Keymaps

```lua
local buf = nil
terminil.setup({
    keys = {
        -- Set it to false to disable keymap
        [vim.g.tnil_keyprefix_n .. 'f'] = false,
        [vim.g.tnil_keyprefix_n .. 'h'] = false,
        [vim.g.tnil_keyprefix_n .. 'v'] = false,
        -- Create your own keymaps. See: vim.keymap.set()
        ['<M-/>'] = {
            function() -- rhs
                if not buf or not terminil.h.is_term(buf) then
                    local data = terminil.open({
                        split = 'below',
                    })
                    buf = data.buf
                else
                    terminil.toggle_buf(buf)
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
terminil.open_multiple(count?, cycle?, opts?)
```

Split according to your style, and it will repeat your configuration in cycles.

```lua
terminil.open_multiple(5, { 'above', { split = 'left', width = 10 }, 'right' })
```

### Switch between terminals and move to different windows

Most functions use the count prefix

```lua
-- Switch to a different terminal in the current window
terminil.switch(-1) -- switch to the previous terminal
terminil.switch(1)  -- switch to the next terminal

terminil.focus(-1)  -- Jump to the previous terminal window
terminil.focus(1)   -- Jump to the next terminal window
```

- Default keymaps
  - `vim.g.tnil_keyprefix_t + e` Switch to the next terminal
  - `vim.g.tnil_keyprefix_n + e` Switch to the next terminal
  - `vim.g.tnil_keyprefix_t + w` Switch to the previous terminal
  - `vim.g.tnil_keyprefix_n + w` Switch to the previous terminal

Use indexes for control

```lua
terminil.switch_in_order(idx?: number)
terminil.open_in_order(idx?: number)

-- For example: If you hide a window or terminal and it has the number 1
-- then you press the key combination `1<leader>tt` and it will open the terminal.
vim.keymap.set('n', '<leader>tt', terminil.open_in_order)
```

### Hide and close the terminal

```lua
terminil.hide(buf?: number)
terminil.close(buf?: number)
```

### Toggle terminal

```lua
terminil.toggle('current')  -- Toggle current terminal
terminil.toggle('previous') -- Toggle previous terminal
terminil.toggle_buf(buf: number)    -- Toggle terminal buf
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
terminil.select(behavior?: 'open'|'switch'|'close', ui_select?)
```

- Default keymaps
  - `vim.g.tnil_keyprefix_n + s`
    - It uses a count prefix to select behavior in a specific order. Default: `open`
      - 1 `open`
      - 2 `switch`
      - 3 `close`
    - Ex: `2<key>` to use the `switch` behavior

### termonly(...)

Similar to the `tabonly` command. See `:tabonly`

```lua
-- `behavior` default is 'hide'. Be careful when using 'close'.
-- 'buf'      default is current buffer
terminil.termonly(behavior?: 'close'|'hide', buf?: number)
```
