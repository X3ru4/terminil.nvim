# APIs

## Structure

```lua
require('terminil') = {
  add = <function>,
  close = <function>,
  focus = <function>,
  h = {
    buf_get_wins = <function>,
    cmd_to_str = <function>,
    default_split = <function>,
    get_index = <function>,
    is_term = <function>,
    list_normal_win = <function>,
    list_termbufs = <function>,
    list_termwins = <function>,
    open_buf = <function>,
    prevbuf = <integer>,
    setup_autocmds = <function>,
    setup_keys = <function>,
    size = <function>,
    windata = <table>
  },
  hide = <function>,
  open = <function>,
  open_in_order = <function>,
  open_multiple = <function>,
  select = <function>,
  setup = <function>,
  switch = <function>,
  switch_in_order = <function>,
  termonly = <function>,
  toggle = <function>,
  toggle_buf = <function>
}

```

### add({count}, {open})

Create one or more different terminal buffers.
It can inherit the configuration of the currently open terminal window.

- Parameters:
  - `count`: (integer?) Number of buffers to add. Default uses vim.v.count1.
  - `open`: (boolean?) If `true` it will open the last created buffer.

### close({buf})

Close the terminal

- Parameters:
  - `buf`: (integer?) The buffer ID of the terminal you want to close.
    The default will be the current buffer.

### focus({direction}, {count})

Focus on a terminal window in ascending or descending order

- Parameters:
  - `direction`: (-1|1) Let `1` be in ascending order and `-1` in descending order.
  - `count`: (integer?) Number of increases and decreases for each time.

### h.buf_get_wins({buf})

- Parameters:
  - `buf`: (integer) Buffer id

- Return: (integer[]) Returns a list containing the windows that are
  currently open in a buffer on a given tab page

### h.cmd_to_str({cmd})

- Parameters:
  - `cmd`: (string|string[]) Sigma command

- Return: (string)

### h.default_split({split})

Get the default split

- Parameters:
  - `split`: ('horizontal'|'vertical') Split direction

- Return: ('below'|'above'|'right'|'left')

### h.get_index({buf})

Get the index of the buffer in the terminal buffer list.

- Parameters:
  - `buf`: (integer) Buffer id. By default, it will use the current buffer.

- Return: (integer|nil)

### h.is_term(buf)

Check if that buffer is a terminal buffer. If it is, return `true`;
otherwise, return `false`.

- Parameters:
  - `buf`: (integer) Buffer id

- Return: (boolean)

### h.list_normal_win()

- Return: (integer[]) Returns a list of normal windows

### h.list_termbufs()

- Return: (integer[]) Returns a list of terminal buffers

### h.list_termwins()

- Return: (integer[]) Returns a list of currently open terminal windows

### h.open_buf(buf, win_config)

Open terminal buffer more intelligently

- Parameters:
  - `buf`: (integer) Buffer id
  - `win_config`: (vim.api.keyset.win_config?) See `nvim_open_win()`

### h.prevbuf

This variable stores the previously opened terminal buffer.
There is a similar variable `vim.t.tnil_prevbuf` but it's in the tabpage scope.
Default value: `0`. Note that `vim.t.tnil_prevbuf` may be `nil`.

- Type: (integer)

### h.setup_autocmds()

Set up autocmds

### h.setup_keys(keys)

Set up keymaps

### h.size(target, percent)

Calculate the ratio of the height or width.

- Parameters:
  - `target`: ('height'|'width')
  - `percent`: (number) 0.0 -> 1.0

- Return: (integer)

### h.windata

The variable contains the window configurations for each buffer.

- Type: (vim.api.keyset.win_config[])

### hide(buf)

Hide the terminal

- Parameters:
  - `buf`: (integer) Buffer ID. The default is the current buffer.

### open({win_config}, {opts})

Open the terminal with a separate configuration window via `win_config`.

- Parameters:
  - `win_config`: (vim.api.keyset.win_config?) See `nvim_open_win()`
  - `opts`: (terminil.open.opts?) has the following options
    - `cmd`: (string|string[]?)
    - `default`: (boolean?) If set to `true`, it will use the default window
      configuration from `M.config.win_config`, and vice versa.
    - `shell`: (string?) Set the terminal shell
    - `buf`: (integer?)
    - `buf_call`: (fun(buf: integer)?) This function will be called within
      the `nvim_buf_call` function.
- Return: ({ buf: integer, win: integer? })

### open_in_order

### open_multiple

### select

### setup

### switch

### switch_in_order

### termonly

### toggle

### toggle_buf
