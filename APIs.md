# APIs

## M.open

Open the terminal with a separate configuration window via `win_config`.

- Parameters:
  - `win_config`: (vim.api.keyset.win_config?) See `api-win_config`
  - `opts`: (terminil.open.opts?) has the following options
    - `cmd`: (string|string[]?)
    - `default`: (boolean?) If set to `true`, it will use the default window
      configuration from `M.config.win_config`, and vice versa
    - `shell`: (string?) Set the terminal shell
    - `buf`: (integer?)
    - `buf_call`: (fun(buf: integer)?) This function will be called within
      the `nvim_buf_call` function
- Return: { buf: integer, win: integer? }

## 😿
